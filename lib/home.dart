import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dynamic Feature Modules Test")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed("/dynamic_module_1");
              },
              child: Text("dynamic_module_1"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed("/dynamic_module_2");
              },
              child: Text("dynamic_module_2"),
            ),
          ],
        ),
      ),
    );
  }
}
