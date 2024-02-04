import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:language_code/language_code.dart';
import 'package:mz_rsa_plugin/mz_rsa_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_rsa3/simple_rsa3.dart';
import 'package:encrypt/encrypt.dart' as en;
import 'package:pointycastle/api.dart' as crypto;

class TestApi extends StatefulWidget {
  const TestApi({super.key});

  @override
  State<TestApi> createState() => _TestApiState();
}

class _TestApiState extends State<TestApi> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // encrypt
  final publicKey = dotenv.env["PUBLIC_DEC_KEY"];
  var simpleRsa = SimpleRsa3();

  // api url
  final uri = Uri.https("dev.adswiz.net", "api/");

  // 언어코드
  static var language = LanguageCode.rawCode;

  //국가코드
  static var countryCode = LanguageCode.rawCode == "ko"
      ? "KR"
      : LanguageCode.rawCode == "en"
          ? "US"
          : LanguageCode.rawCode == "ja"
              ? "JP"
              : LanguageCode.rawCode == "zh"
                  ? "CN"
                  : "";

  // os플랫품
  static var os = Platform.isIOS ? "ios" : "android";

  // os버전

  // 문자열 100바이트 자르기
  String sliceByByte(String str, int maxByte) {
    int b = 0;
    int i = 0;
    int c;
    for (b = i = 0; i < str.length && (c = str.codeUnitAt(i)) != 0;) {
      b += c >> 7 != 0 ? 2 : 1;
      if (b > maxByte) break;
      i++;
    }
    return str.substring(0, i);
  }

  // ---------------------
  // FCM key
  // ---------------------
  String? _fcmkey;

  Future<void> _getToken() async {
    var prefs = await SharedPreferences.getInstance();
    _fcmkey = prefs.getString("fcmkey");
    print(_fcmkey);
    setState(() {
      _fcmkey = prefs.getString("fcmkey");
    });
  }

  // ---------------------
  // Device UUID
  // ---------------------
  String? _uuid;

  Future<void> _initUUID() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      _uuid = prefs.getString("uuid");
    });
  }

  // ---------------------
  // Device Info
  // ---------------------
  String? _platformVersion;
  String? _modelName;

  Future<void> _getDeviceInfo() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      _platformVersion = prefs.getString("platformVersion");
      _modelName = prefs.getString("modelName");
    });
  }

  final _package = os == "ios"
      ? "com.adswiztest.ios"
      : os == "android"
          ? "com.adswiztest.android"
          : "";

  Future<Map<String, dynamic>> getDefaultParams() async {
    Map<String, dynamic> param = {
      'method': "getPolicy",
      'type': '2',
      'fcm_key': _fcmkey,
      'os': os,
      'os_version': _platformVersion,
      'device_id': _uuid,
      'device_name': _modelName,
      'language': language,
      'country': countryCode,
      'package': _package,
      'version_name': '',
      'version_code': '',
      'member_key': "",
      'use_unlock_ads': "unlockAds",
    };
    return param;
  }

  Future<void> _initializeData() async {
    await _initUUID();
    await _getToken();
    await _getDeviceInfo();
    await getDefaultParams();
    // await _callApi();
  }

  // ---------------------
  // Api call
  // ---------------------

  // String decryptPublicKey(String public, String content){
  //   RSAKeyParser parser = RSAKeyParser();
  //   RSAPublicKey publicKey = parser.parse(public) as RSAPublicKey;
  //   AsymmetricBlockCipher cipher = PKCS1Encoding(RSAEngine());
  //   cipher
  //     .init(false, PublicKeyParameter<RSAPublicKey>(publicKey));
  //   return utf8.decode(cipher.process(Encrypted.fromBase64(content).bytes));
  // }

  Future<void> _callApi() async {
    var params = await getDefaultParams();
    var maxByte = 100;
    var encDataArray = <String>[];
    String? jsonToStr = jsonEncode(params);
    print("문자열파람:$jsonToStr");
    String? enc = base64.encode(utf8.encode(jsonToStr));
    print("base64:: $enc");

    var currentIndex = 0;

    while (currentIndex < enc.length) {
      var remainStr = enc.substring(currentIndex);
      var chunk = sliceByByte(remainStr, maxByte);
      // var encData =
      // await MzRsaPlugin.encryptStringByPublicKey(chunk, publicKey ?? "");
      var encData = await simpleRsa.encryptString(chunk, publicKey!);
      encDataArray.add(encData ?? '');

      currentIndex += chunk.length;
    }

    var realData = encDataArray.join();
    print("리얼데이터:: $realData");

    final res = await http.post(uri,
        headers: {'Content-Type': 'application/json'}, body: realData);

    if (res.statusCode == 200) {
      print("success!");
      var dataFromDB = res.body;
      print("데이터 :: $dataFromDB");
      var arrStr = dataFromDB.split("=");

      var count = 0;
      String strDecData = '';
      while(arrStr[count] != ""){
        var msg = await MzRsaPlugin.decryptStringByPublicKey(arrStr[count], publicKey!);
        print("결과물 :: $msg");
        count++;
      }

      // var encData = await simpleRsa.encryptString(chunk, utf8.decode(base64.decode(publicKey!)));
      // while (count < dataFromDB.length) {
      //   var remainStr = dataFromDB.substring(count);
      //   var chunk = sliceByByte(remainStr, maxByte);
      //   var decData =
      //       await simpleRsa.decryptString(chunk, publicKey!);
      //
      //   encDataArray.add(decData??"");
      //   count += chunk.length;
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("테스트 API"),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              ElevatedButton(onPressed: _callApi, child: Text('API콜')),
              // ElevatedButton(onPressed: testApi, child: Text("테스트콜")),
              // Text("fcm : $_fcmkey"),
            ],
          )
        ],
      ),
    );
  }
}
