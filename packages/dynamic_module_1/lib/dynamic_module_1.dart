import 'package:flutter/material.dart';
import 'package:demo_dynamic_feature_modules/demo_dynamic_feature_modules.dart';

@pragma('dyn-module:entry-point')
Object? dynamicModuleEntrypoint() {
  MyRouter.routes["/dynamic_module_1"] = (BuildContext context) =>
      const DynamicModule1();
  return true;
}

class DynamicModule1 extends StatefulWidget {
  const DynamicModule1({super.key});

  @override
  State<DynamicModule1> createState() => _DynamicModule1State();
}

class _DynamicModule1State extends State<DynamicModule1> {
  int _counter = refreshCount;

  void _incrementCounter() {
    setState(() {
      refreshCount += 1;
      _counter = refreshCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("DynamicModule1"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
