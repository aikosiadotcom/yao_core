import 'package:get/get.dart';
import 'package:yao_core/src/manager/middleware.dart';

class RequestMixin {
  Request get request => Get.find<Request>();
}
