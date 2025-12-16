import 'dart:io';

import 'package:path/path.dart' as path;

Uri ensureFolderPath(String path) {
  String uriPath = Uri.file(path).toString();
  if (!uriPath.endsWith('/')) {
    uriPath = '$uriPath/';
  }
  return Uri.base.resolve(uriPath);
}

final sdkRoot = ensureFolderPath(
  path.dirname(path.dirname(Platform.resolvedExecutable)),
);
final repoRoot = ensureFolderPath(path.current);
final modulesRoot = repoRoot.resolve("packages/");

final Uri aotRuntimeBin = sdkRoot.resolve('bin/dartaotruntime');

final Uri genSnapshotBin = sdkRoot.resolve('bin/utils/gen_snapshot');

final Uri dart2bytecodeSnapshot = sdkRoot.resolve(
  'bin/snapshots/dart2bytecode.dart.snapshot',
);

final Uri genKernelSnapshot = sdkRoot.resolve(
  'bin/snapshots/gen_kernel_aot.dart.snapshot',
);

final Uri flutterPatchedSdkRoot = ensureFolderPath(
  "${path.dirname(path.dirname(path.dirname(Platform.resolvedExecutable)))}/artifacts/engine/common/flutter_patched_sdk_product/",
);

final Uri vmPlatformStrongDill = flutterPatchedSdkRoot.resolve(
  'platform_strong.dill',
);

final Uri vmOutlineStrongDill = flutterPatchedSdkRoot.resolve(
  'vm_outline_strong.dill',
);

Future compileFlutterKernel({
  required String repoName,
  required String enterPoint,
  required bool isAot,
}) async {
  print('start buildKernel $repoName ..');
  var aotTag = isAot ? "aot" : "no_aot";
  var args = [
    genKernelSnapshot.toFilePath(),
    '--target',
    'flutter',
    '--packages',
    '${repoRoot.toFilePath()}.dart_tool/package_config.json',
    '-Ddart.vm.profile=false',
    '-Ddart.vm.product=true',
    if (isAot) '--aot' else '--no-aot',
    '--no-embed-sources',
    '--platform',
    vmPlatformStrongDill.toFilePath(),
    '--output',
    'build/${repoName}_$aotTag.dill',
    '--verbosity=all',
    '--dynamic-interface',
    '${repoRoot.toFilePath()}dynamic_interface.yaml',
    '${repoRoot.toFilePath()}$enterPoint',
  ];

  await runProcess(
    aotRuntimeBin.toFilePath(),
    args,
    repoRoot.toFilePath(),
    'kernel $aotTag $repoName/$enterPoint',
  );

  if (isAot) {
    var args = [
      '--snapshot-kind=app-aot-elf',
      '--elf=build/${repoName}_$aotTag.snapshot',
      'build/${repoName}_$aotTag.dill',
    ];
    print('start genSnapshotBin ${genSnapshotBin} ');
    await runProcess(
      genSnapshotBin.toFilePath(),
      args,
      repoRoot.toFilePath(),
      'aot snapshot  $repoName/$enterPoint',
    );
  }
}

Future compileDynamicModule({
  required String repoName,
  required String name,
  required String enterPoint,
  required String out,
  required bool isAot,
}) async {
  print('start compile module $name..');
  var modulePath = modulesRoot.resolve(name);
  print('repoRoot is  $repoRoot');
  print('modulesRoot is  $modulesRoot');
  print('modulePath is  $modulePath');
  print('enterPoint is  $enterPoint');
  var aotTag = isAot ? "aot" : "no_aot";
  var args = [
    '--disable-dart-dev',
    dart2bytecodeSnapshot.toFilePath(),
    '--platform',
    vmPlatformStrongDill.toFilePath(),
    '--target',
    'flutter',
    '--packages',
    '${repoRoot.toFilePath()}.dart_tool/package_config.json',
    '-Ddart.vm.profile=false',
    '-Ddart.vm.product=true',
    '--import-dill',
    'build/${repoName}_$aotTag.dill',
    '--validate',
    '${repoRoot.toFilePath()}dynamic_interface.yaml',
    '--verbosity=all',
    '--output',
    out,
    '${modulePath.toFilePath()}/$enterPoint',
  ];
  await runProcess(
    aotRuntimeBin.toFilePath(),
    args,
    repoRoot.toFilePath(),
    'compile bytecode ${modulePath.toFilePath()}/$enterPoint',
  );
}

Future<ProcessResult> runProcess(
  String command,
  List<String> arguments,
  String workingDirectory,
  String message,
) async {
  print('command:\n$command ${arguments.join(' ')} \n from $workingDirectory');
  final result = await Process.run(
    command,
    arguments,
    workingDirectory: workingDirectory,
  );
  print('Exit code: ${result.exitCode}');
  if (result.exitCode != 0) {
    print('STDOUT: ${result.stdout}');
    print('STDERR: ${result.stderr}');
    throw 'Error on $message: $command ${arguments.join(' ')} from $workingDirectory\n\n'
        'stdout:\n${result.stdout}\n\n'
        'stderr:\n${result.stderr}';
  } else {
    print('STDOUT: ${result.stdout}');
    print('STDERR: ${result.stderr}');
  }
  return result;
}
