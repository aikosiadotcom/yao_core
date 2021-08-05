import 'package:flutter/material.dart';

typedef CbRetry = Future<void> Function();

///Controller perlu init manual karena belum ada binding
class ErrorRetrier extends StatelessWidget {
  final CbRetry cbRetry;
  final String message;
  ErrorRetrier(this.message, this.cbRetry);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(this.message),
        ),
        SizedBox(
          height: 12,
        ),
        ElevatedButton(onPressed: () => cbRetry(), child: Text('Retry')),
      ],
    ));
  }
}
