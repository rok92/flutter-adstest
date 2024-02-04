import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:language_code/language_code.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetApi {
  static var language = LanguageCode.rawCode;
  static var countryCode = LanguageCode.rawCode == "ko"
      ? "KR"
      : LanguageCode.rawCode == "en"
          ? "US"
          : LanguageCode.rawCode == "ja"
              ? "JP"
              : LanguageCode.rawCode == "zh"
                  ? "CN"
                  : "";
  static var os = Platform.isIOS ? "ios" : "android";
  static var osVersion = Platform.version;
  String sliceByByte(String str, int maxByte) {
    int b = 0;
    int i = 0;
    int c;
    for (b = i = 0; (c = str.codeUnitAt(i)) != 0;) {
      b += c >> 7 != 0 ? 2 : 1;
      if (b > maxByte) break;
      i++;
    }
    return str.substring(0, i);
  }
}
