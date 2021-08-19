import 'package:flutter/material.dart';
import 'package:get/get.dart';

class YaoDialog {
  void error(String message) {
    Get.snackbar("", "",
        titleText: Text("Error"),
        icon: Icon(Icons.error),
        duration: Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        shouldIconPulse: true,
        isDismissible: true,
        messageText: Text(message));
  }

  void info(String message) {
    Get.snackbar("", "",
        titleText: Text("Info"),
        icon: Icon(Icons.checklist),
        duration: Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
        shouldIconPulse: true,
        isDismissible: true,
        messageText: Text(message));
  }
}
