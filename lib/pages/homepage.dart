import 'dart:convert';
import 'dart:io';
import 'package:adswiztest/utils/api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:twitter_login/twitter_login.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:device_uuid/device_uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_information/device_information.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  User? _user;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });
    });
    // uuid init
    _initUUID();
    // FCM KEY
    // getToken();
    _getToken();
    _getDeviceInfo();
    // Candle stick
    fetchCandles().then((value) {
      setState(() {
        candles = value;
      });
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

  // ---------------------
  // FCM key
  // ---------------------
  String? _token;
  void _getToken() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString("fcmkey");
    });
  }

  // ---------------------
  // Google Login
  // ---------------------
  String _gName = "";
  String _gEmail = "";

  Future<void> googleLogin() async {
    GoogleSignIn _googleSignIn = GoogleSignIn();
    GoogleSignInAccount? _account = await _googleSignIn.signIn();

    if (_account != null) {
      print("name = ${_account.displayName}");
      GoogleSignInAuthentication _authentication =
          await _account.authentication;
      OAuthCredential _googleCredential = GoogleAuthProvider.credential(
        idToken: _authentication.idToken,
        accessToken: _authentication.accessToken,
      );
      UserCredential _credential =
          await _auth.signInWithCredential(_googleCredential);
      if (_credential.user != null) {
        _user = _credential.user;
        print("credential : $_user");
      }

      setState(() {
        _gName = _account.displayName!;
        _gEmail = _account.email;
      });
    }
  }

  // ---------------------
  // Facebook Login
  // ---------------------
  String _fUserName = '';
  String _fUserEmail = '';

  Future<UserCredential> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);
    final userData = await FacebookAuth.instance.getUserData();
    print(userData);
    setState(() {
      _fUserEmail = userData['email'];
      _fUserName = userData['name'];
    });
    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  // ---------------------
  // Twitter Login
  // ---------------------
  String _tEmail = "";
  String _tName = "";
  bool _tStatus = false;

  Future<UserCredential> signInWithTwitter() async {
    final apikey = dotenv.env['TWITTER_API'];
    final apiSecret = dotenv.env['TWITTER_API_SECRET'];
    final apiUrl = dotenv.env['TWITTER_URL'];
    final twitterLogin = TwitterLogin(
        apiKey: apikey!, apiSecretKey: apiSecret!, redirectURI: apiUrl!);

    final authResult = await twitterLogin.login();

    final twitterAuthCredential = TwitterAuthProvider.credential(
      accessToken: authResult.authToken!,
      secret: authResult.authTokenSecret!,
    );


    setState(() {
      _tStatus = true;
      _tEmail = authResult.user!.email;
      _tName = authResult.user!.name;
    });
    return await FirebaseAuth.instance
        .signInWithCredential(twitterAuthCredential);
  }

  // ---------------------
  // CandleStick Chart
  // ---------------------
  List<Candle> candles = [];

  Future<List<Candle>> fetchCandles() async {
    final uri = Uri.parse(
        "https://api.binance.com/api/v3/klines?symbol=BTCUSDT&interval=1h");
    final res = await http.get(uri);
    return (jsonDecode(res.body) as List<dynamic>)
        .map((e) => Candle.fromJson(e))
        .toList()
        .reversed
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SNS 로그인 구현 테스트"),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              ElevatedButton(onPressed: googleLogin, child: Text("구글로그인")),
              Text("계정 : $_gEmail"),
              Text("이름 : $_gName"),
              ElevatedButton(
                  onPressed: signInWithFacebook, child: Text('페이스북로그인')),
              Text("계정 : $_fUserEmail"),
              Text("이름 : $_fUserName"),
              ElevatedButton(
                  onPressed: signInWithTwitter, child: Text('트위터로그인')),
              Text("계정 : $_tEmail"),
              Text("이름 : $_tName"),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/adspage");
                  },
                  child: Text("광고페이지로 이동")),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/testapi");
                  },
                  child: Text("api")),
              Text("os버전 : $_platformVersion"),
              Text("모델명 : $_modelName"),
              // Text("os : ${GetApi.os}"),
              Text("$_uuid"),
              // Text("$_token"),
              // ElevatedButton(onPressed: GetApi., child: child)
            ],
          ),
        ],
      ),
    );
  }
}
