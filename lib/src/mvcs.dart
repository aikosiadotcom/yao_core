import 'package:flutter/material.dart' hide Route;
import 'package:get/get.dart';
import 'package:yao_core/src/mixin/request.dart';

import '../yao_core.dart';
import 'mixin/app.dart';
import 'widget/error_retrier.dart';

abstract class YaoService<T> extends GetxService with AppMixin {
  Future<T> run();
}

class YaoView<T> extends StatelessWidget with AppMixin {
  const YaoView({Key? key}) : super(key: key);

  // final String? tag = null;

  T get c => Get.find<YaoController>(tag: Get.currentRoute) as T;

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

  Widget withScaffold(BuildContext context,
      {required Widget Function() child,
      PreferredSizeWidget? appBar,
      bool resizeToAvoidBottomInset = true,
      Widget? bottomNavigationBar}) {
    return Scaffold(
      bottomNavigationBar: bottomNavigationBar,
      appBar: appBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SafeArea(
        child: child(),
      ),
    );
  }

  Widget withState<T>(BuildContext context,
      {required Widget Function() child,
      PreferredSizeWidget? appBar,
      Future Function()? onError,
      bool resizeToAvoidBottomInset = true,
      T? controller,
      Widget? bottomNavigationBar}) {
    StateMixin tmp;
    if (controller == null) {
      tmp = c as StateMixin;
    } else {
      tmp = controller as StateMixin;
    }

    return tmp.obx((state) {
      if (appBar == null) {
        return child();
      }
      return withScaffold(context,
          child: child,
          appBar: appBar,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          bottomNavigationBar: bottomNavigationBar);
    }, onLoading: Builder(
      builder: (BuildContext context) {
        return withScaffold(context, child: () {
          return Container(child: Center(child: CircularProgressIndicator()));
        });
      },
    ), onError: (err) {
      if (onError == null) {
        return withScaffold(context, child: () {
          return ErrorRetrier(err == null ? "" : err, () async {
            await app.navigator.goto(
                "${"/redirect"}?next=${Get.currentRoute}&desc=Memuat ulang...");
            // await Get.offNamed(Get.currentRoute, preventDuplicates: false);
            // await Get.offAndToNamed(Get.currentRoute);
          });
        });
      } else {
        return withScaffold(context, child: () {
          return ErrorRetrier(err == null ? "" : err, () async {
            await onError();
          });
        });
      }
    },
        onEmpty: Center(
          child: Text('Tidak ada data yang ditemukan.'),
        ));
  }
}

abstract class YaoController extends GetxController
    with AppMixin, RequestMixin {}

abstract class YaoControllerWithState<T> extends YaoController
    with StateMixin<T> {}

abstract class YaoControllerCustom extends GetxController
    with AppMixin, RequestMixin {}

abstract class YaoControllerCustomWithState<T> extends YaoControllerCustom
    with StateMixin<T> {}
