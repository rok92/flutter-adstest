import 'package:adswiztest/firebase_options.dart';
import 'package:adswiztest/pages/ads_page.dart';
import 'package:adswiztest/pages/homepage.dart';
import 'package:adswiztest/pages/test_api.dart';
import 'package:adswiztest/pages/unity_ads.dart';
// import 'package:crypto_simple/crypto_simple.dart';
import 'package:device_information/device_information.dart';
import 'package:device_uuid/device_uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ---------------------
  // Admob init
  // ---------------------
  Admob.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // ---------------------
  // Unity init
  // ---------------------
  await UnityAds.init(
      gameId: AdManager.getGameId,
      onComplete: () => print('Initialized Complete'),
      onFailed: (err, message) => print("Initialized Faild : $err $message"));

  var prefs = await SharedPreferences.getInstance();
  // ---------------------
  // FCM key
  // ---------------------
  void getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("토큰:$token");
    prefs.setString("fcmkey", token!);
  }

  getToken();

  // ----------------------------
  // Device UUID, Name, Platform
  // ----------------------------
  final deviceUuidPlugin = DeviceUuid();

  Future<void> initUUID() async {
    String getUUID;
    try {
      getUUID = await deviceUuidPlugin.getUUID() ?? "Unknown uuid version";
      await prefs.setString("uuid", getUUID);
    } on PlatformException {
      getUUID = "Failed to get uuid";
    }
  }
  initUUID();

  Future<void> getDeviceInfo() async {
    String modelName = await DeviceInformation.deviceName;
    var platformVersion = await DeviceInformation.platformVersion;
    await prefs.setString("modelName", modelName);
    await prefs.setString("platformVersion", platformVersion);
  }

  getDeviceInfo();

  // dotenv
  await dotenv.load(fileName: 'assets/config/.env');
  // await CryptoSimple(
  //   superKey: 2023,
  //   subKey: 47,
  //   secretKey: dotenv.env["PUBLIC_DEC_KEY"],
  //   encryptionMode: EncryptionMode.Randomized,
  // );

  // run
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: HomePage(),
      routes: {
        "/adspage": (context) => AdsPage(),
        "/testapi": (context) => TestApi(),
      },
    );
  }
}
