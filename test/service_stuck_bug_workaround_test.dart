import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:yao_core/yao_core.dart';

class MyService extends YaoService {
  int test() {
    return 5;
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
  testWidgets('Service stuck bug workaround ...', (tester) async {
    MyService a = MyService();
    expect(a.test(), 5);
    // expect(tester.takeException(), throwsA(isInstanceOf<TimeoutException>()));
  });
}
