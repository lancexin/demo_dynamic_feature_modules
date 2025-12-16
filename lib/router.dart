import 'package:demo_dynamic_feature_modules/home.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_modules/dynamic_modules.dart';
import 'package:flutter/services.dart' show rootBundle;

class MyRouter {
  static final String home = "/home";

  static final Map<String, Widget Function(BuildContext)> routes = {
    "/home": (BuildContext context) => const Home(),
    "/": (BuildContext context) => const Home(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    print("onGenerateRoute ${settings.name}");
    var routerFun = routes[settings.name];
    print("routerFun is  ${routerFun}");
    if (routerFun == null) {
      return MaterialPageRoute(
        builder: (context) => DynamicModuleLoader(name: settings.name!),
      );
    }

    return MaterialPageRoute(builder: (context) => routerFun.call(context));
  }
}

class DynamicModuleLoader extends StatefulWidget {
  final String name;
  const DynamicModuleLoader({super.key, required this.name});

  @override
  State<DynamicModuleLoader> createState() => _DynamicModuleLoaderState();

  String get library => "package:$name$name.dart";
  String get module => "assets/modules$name.bytecode";
}

class _DynamicModuleLoaderState extends State<DynamicModuleLoader> {
  @override
  void initState() {
    super.initState();
  }

  Widget _widgetError(String error) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text(error)),
    );
  }

  Future createLoadFuture() {
    var uri = Uri.parse(widget.library);
    if (isModuleLoaded(uri)) {
      return loadModuleFromUri(uri);
    }

    return rootBundle.load(widget.module).then((value) {
      return loadModuleFromBytes(
        Uri.parse(widget.library),
        value.buffer.asUint8List(),
      );
    });
  }

  Future<Object?> get loadFuture {
    return createLoadFuture()
        .then((r) async {
          //模拟字节码加载过程
          await Future.delayed(Duration(seconds: 2));
          return r;
        })
        .onError((error, stackTrace) {
          FlutterError.dumpErrorToConsole(
            FlutterErrorDetails(exception: error!, stack: stackTrace),
            forceReport: true,
          );
        });
  }

  Widget _widgetLoading() {
    return Scaffold(body: Center(child: const CircularProgressIndicator()));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object?>(
      future: loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return _widgetError('Error: ${snapshot.error}');
          }
          var routeFun = MyRouter.routes[widget.name];
          return routeFun?.call(context) ??
              _widgetError('Error: Router ${widget.name} not found');
        }
        return _widgetLoading();
      },
    );
  }
}
