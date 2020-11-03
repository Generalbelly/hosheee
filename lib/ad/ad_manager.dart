import 'dart:io';

import 'package:hosheee/main.dart';

class AdManager {

  static String get appId {
    if (Platform.isAndroid) {
      return "ca-app-pub-1121620757092541~9787788742";
    } else if (Platform.isIOS) {
      return "ca-app-pub-1121620757092541~7421140549";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get bannerAdUnitId {
    if (EnvironmentConfig.BUILD_ENV == "dev") {
      return "ca-app-pub-3940256099942544/2934735716";
    }
    if (Platform.isAndroid) {
      return "ca-app-pub-1121620757092541/2360385558";
    } else if (Platform.isIOS) {
      return "ca-app-pub-1121620757092541/6926316526";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

}
