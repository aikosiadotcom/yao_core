import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
              "No view found. please call method next() or render() on instance of Response."),
        ),
      ),
    );
  }
}
