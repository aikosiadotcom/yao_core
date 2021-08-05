import 'package:yao_core/src/app.dart';

late final App _app;
bool _initialized = false;
// ignore: non_constant_identifier_names
App Yao() {
  if (_initialized == false) {
    _app = App();
    _initialized = true;
  }

  return _app;
}
