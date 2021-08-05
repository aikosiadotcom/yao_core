import 'package:get/get.dart';

import '../exception/exists.dart';
import '../mvcs.dart';

class ServiceManager {
  List<Future<void> Function()> services = [];

  ServiceManager();

  void add<T extends YaoService>(T instance, {String? tag}) {
    services.add(() => inject<T>(instance, tag: tag));
  }

  Future<void> inject<T extends YaoService>(T instance, {String? tag}) async {
    try {
      this.find<T>(tag: tag);
      throw ExistsException("Service ${instance.runtimeType} exists");
    } catch (err) {}

    await Get.putAsync<T>(() async {
      return await instance.run();
    }, tag: tag);
  }

  T find<T>({String? tag}) {
    return Get.find<T>(tag: tag);
  }

  Future<void> run() async {
    for (final service in services) {
      await service();
    }
  }
}
