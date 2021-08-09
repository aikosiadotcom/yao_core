import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmptyViewController extends GetxController {
  final message =
      "No view found. please call method next() or render() on instance of Response."
          .obs;
}

class EmptyView extends StatelessWidget {
  final c = EmptyViewController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(c.message.value),
        ),
      ),
    );
  }
}
