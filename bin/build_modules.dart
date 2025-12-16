import 'env.dart';

void main() async {
  await compileFlutterKernel(
    repoName: "demo_dynamic_feature_modules",
    enterPoint: "lib/main.dart",
    isAot: false,
  );

  await compileFlutterKernel(
    repoName: "demo_dynamic_feature_modules",
    enterPoint: "lib/main.dart",
    isAot: true,
  );
  await compileDynamicModule(
    repoName: "demo_dynamic_feature_modules",
    enterPoint: "lib/dynamic_module_1.dart",
    name: 'dynamic_module_1',
    out: 'assets/modules/dynamic_module_1.bytecode',
    isAot: false,
  );
  await compileDynamicModule(
    repoName: "demo_dynamic_feature_modules",
    enterPoint: "lib/dynamic_module_2.dart",
    name: 'dynamic_module_2',
    out: 'assets/modules/dynamic_module_2.bytecode',
    isAot: false,
  );
}
