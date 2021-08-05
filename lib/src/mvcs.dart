import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'mixin/app.dart';

abstract class YaoService<T> extends GetxService with AppMixin {
  Future<T> run();
}

abstract class YaoView<T> extends StatelessWidget {
  const YaoView({Key? key}) : super(key: key);

  final String? tag = null;

  T get c => GetInstance().find<YaoController>(tag: tag) as T;

  @override
  Widget build(BuildContext context);
}

abstract class YaoController extends GetxController with AppMixin {}
