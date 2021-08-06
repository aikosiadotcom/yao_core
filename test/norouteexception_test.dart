import 'package:flutter_test/flutter_test.dart';
import 'package:yao_core/yao_core.dart';

void main() {
  testWidgets('NoRouteException ...', (tester) async {
    final app = Yao();
    await app.runWithTester(tester);

    final a = find.textContaining("NoRouteException");
    expect(a, findsOneWidget);
  });
}
