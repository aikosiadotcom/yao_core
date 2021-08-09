import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:yao_core/yao_core.dart';

class MyService extends YaoService {
  void test() {
    print('calling Method test() on MyService');
  }

  @override
  Future run() async {
    print('stuck here');
    await Future(() {
      print('ready');
    });
    print('end');
  }
}

void main() {
  testWidgets('Service Stuck bug ...', (tester) async {
    final app = Yao();
    app.inject(MyService());
    await app.runWithTester(tester);
    // expect(tester.takeException(), throwsA(isInstanceOf<TimeoutException>()));
  }, timeout: Timeout(Duration(seconds: 5)));
}
