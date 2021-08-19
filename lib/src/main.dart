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

class _Route {
  final String root;
  final String rootIdentifier;
  final String classNameSuffix;
  _Route(
      {this.rootIdentifier = "root",
      this.root = "/",
      this.classNameSuffix = "Router"});

  String of<T extends YaoRouter>([T? type]) {
    String _res = type == null ? T.toString() : type.runtimeType.toString();
    String res = _res
        .toString()
        .split(new RegExp(r"(?<=[a-z])(?=[A-Z])"))
        .map((e) => e.toLowerCase())
        .where((element) => element != classNameSuffix.toLowerCase())
        .toList()
        .join("/");
    if (res == rootIdentifier) {
      return root;
    }

    return "/$res";
  }
}

class Route {
  static String get root => _Route().root;
  static of<T extends YaoRouter>([T? type]) {
    return _Route().of<T>(type);
  }
}

class YaoRouter {
  final router = Yao().Router();

  // Future? open<T extends YaoRouter>([T? route]) {
  //   String _route = "";
  //   if (route != null) {
  //     _route = Route.of<T>(route);
  //   }
  //   return Yao().navigator.goto(_route);
  // }
}
