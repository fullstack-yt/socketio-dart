import 'dart:io' show Platform;

class AppProperties {
  static late bool isIOS;

  static init() async {
    isIOS = Platform.isIOS;
  }
}
