import 'package:get/get.dart';

import 'main.dart';

class YaoNavigator {
  late final String _root;
  YaoNavigator({String root = ""}) {
    _root = root;
  }

  Future<T?>? goto<T>(
    String page, {
    dynamic arguments,
    int? id,
    Map<String, String>? parameters,
  }) {
    return Get.offAndToNamed(page,
        arguments: arguments, id: id, parameters: parameters);
  }

  Future<T?>? root<T>() {
    if (_root.isEmpty) {
      return this.goto(Route.root);
    }

    return this.goto(_root);
  }
}
