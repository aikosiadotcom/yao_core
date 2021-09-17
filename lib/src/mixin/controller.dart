import 'package:get/get.dart';

class ControllerMixin<T> {
  T get c => Get.find<T>(tag: tag);

  String? get tag => null;
}
