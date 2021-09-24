import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cool_alert/cool_alert.dart';

class YaoLoader {
  void hide() {
    Navigator.of(Get.context!, rootNavigator: true).pop();
  }

  void show() {
    CoolAlert.show(
        context: Get.context!,
        type: CoolAlertType.loading,
        barrierDismissible: false);
  }
}

class YaoDialog {
  void error(String message) {
    CoolAlert.show(
        context: Get.context!, type: CoolAlertType.error, text: message);
  }

  void info(String message) {
    CoolAlert.show(
        context: Get.context!, type: CoolAlertType.info, text: message);
  }

  Future confirm(
      {String message = "Apakah anda yakin ?",
      required Future Function() onConfirm}) async {
    await CoolAlert.show(
        context: Get.context!,
        confirmBtnText: "Ya",
        cancelBtnText: "Tidak",
        type: CoolAlertType.confirm,
        text: message,
        onConfirmBtnTap: () async {
          Navigator.pop(Get.context!);
          await onConfirm();
        });
  }
}
