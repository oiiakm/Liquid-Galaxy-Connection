import 'package:get/get.dart';

class ResponsiveUtils {
  static double calculateButtonWidth() {
    double screenWidth = Get.width;

    if (screenWidth > 600) {
      return screenWidth * 0.3;
    } else {
      return screenWidth * 0.4;
    }
  }

  static double calculateButtonHeight() {
    double screenWidth = Get.width;

    if (screenWidth > 600) {
      return screenWidth / 10;
    } else {
      return screenWidth / 5;
    }
  }

  static double calculateTextSize() {
    double screenWidth = Get.width;

    if (screenWidth > 600) {
      return screenWidth / 40;
    } else {
      return screenWidth / 25;
    }
  }
}
