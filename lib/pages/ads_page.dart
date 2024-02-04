import 'dart:io';

import 'package:adswiztest/pages/unity_ads.dart';
import 'package:adswiztest/pages/facebook_audience.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdsPage extends StatefulWidget {
  const AdsPage({super.key});

  @override
  State<AdsPage> createState() => _AdsPageState();
}

class _AdsPageState extends State<AdsPage> {
  // ----------------------------------
  // Google Admob Reward(Android, IOS)
  // ----------------------------------
  late AdmobReward rewardAd;

  String? getRewardId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    }
    return null;
  }

  String? admobReward;

  void admobHandler(
      AdmobAdEvent event, Map<String, dynamic>? args, String adType) async {
    switch (event) {
      case AdmobAdEvent.rewarded:
        setState(() {
          admobReward = '${args!['amount']}';
        });
        break;
      default:
    }
  }

  // -------------------------------
  // Facebook Native(Android, IOS)
  // -------------------------------
  FacebookNativeAd _nativeAd() {
    return FacebookNativeAd(
      placementId: "IMG_16_9_APP_INSTALL#2312433698835503_2964952163583650",
      adType: NativeAdType.NATIVE_AD_VERTICAL,
      width: double.infinity,
      height: 300,
      backgroundColor: Colors.white,
      titleColor: Colors.black,
      descriptionColor: Colors.black,
      buttonColor: Colors.blueAccent,
      buttonTitleColor: Colors.white,
      buttonBorderColor: Colors.white,
      listener: (result, value) {
        print("Native Ad: $result --> $value");
      },
      keepExpandedWhileLoading: true,
      expandAnimationDuraion: 1000,
    );
  }

  // -------------------------------
  // Facebook Reward(Android, IOS)
  // -------------------------------
  // Android
  bool _isRewardedAdLoaded = false;

  void _loadRewardedVideoAd() {
    FacebookRewardedVideoAd.loadRewardedVideoAd(
      placementId: "IMG_16_9_APP_INSTALL#2312433698835503_2650502525028617",
      listener: (result, value) {
        print("Facebook Rewarded Ad: $result --> $value");
        if (result == RewardedVideoAdResult.LOADED) _isRewardedAdLoaded = true;
        if (result == RewardedVideoAdResult.VIDEO_COMPLETE)

        /// Once a Rewarded Ad has been closed and becomes invalidated,
        /// load a fresh Ad by calling this function.
        if (result == RewardedVideoAdResult.VIDEO_CLOSED &&
            (value == true || value["invalidated"] == true)) {
          _isRewardedAdLoaded = false;
        }
      },
    );
  }

  // IOS Facebook Reward load
  final fbReward = FBRewardedAd();

  void _loadRwVideo() async {
    await fbReward.loadRewardedVideoAd(dotenv.env['FB_AUDIENCE_IOS']);
    _loadRwVideo();
  }

  // Facebook Reward Show
  void _showRewardedAd() {
    if (Platform.isAndroid) {
      if (_isRewardedAdLoaded == true) {
        FacebookRewardedVideoAd.showRewardedVideoAd();
        _loadRewardedVideoAd();
      } else {
        print("Rewarded Ad not yet loaded!");
      }
    } else if (Platform.isIOS) {
      fbReward.showRewardedAd();
      print(fbReward.showRewardedAd());
    }
  }

  // ------------------------
  // Connecting Test
  // ------------------------
  int _random = 0;
  String _rere = "";

  void _generateRandom() async {
    _random = await fbReward.generate() ?? _random;
    setState(() {});
  }

  void _resultClose() async {
    _rere = await fbReward.rewardedVideoAdDidClose() ?? _rere;
  }

  // ------------------------
  // Platform Initializing
  // ------------------------
  @override
  void initState() {
    super.initState();
    // Google init
    rewardAd = AdmobReward(
      adUnitId: getRewardId()!,
      listener: (AdmobAdEvent event, Map<String, dynamic>? args) {
        if (event == AdmobAdEvent.closed) rewardAd.load();
        admobHandler(event, args, "Reward");

        if (event == AdmobAdEvent.rewarded) {
          print(admobReward);
        }
      },
    );
    // Facebook init
    FacebookAudienceNetwork.init(
      testingId: "a77955ee-3304-4635-be65-81029b0f5201",
      iOSAdvertiserTrackingEnabled: true,
    );
    WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) async {
      // Unity
      await AdManager.loadUnityAd();

      // Facebook Reward Android
      _loadRewardedVideoAd();

    });
// Facebook Reward IOS
    _loadRwVideo();

    rewardAd.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("광고 페이지"),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              ElevatedButton(
                  onPressed: () async {
                    if (await rewardAd.isLoaded) {
                      rewardAd.show();
                    } else {
                      print("rewardAd is not loaded!");
                    }
                  },
                  child: Text("구글광고")),
              Text("구글광고 reward : $admobReward"),
              ElevatedButton(
                onPressed: () async {
                  await AdManager.showRwAd();
                },
                child: const Text('유니티광고'),
              ),
              ElevatedButton(
                onPressed: _loadRwVideo,
                child: const Text('광고로드'),
              ),
              ElevatedButton(
                onPressed: _showRewardedAd,
                child: const Text('페이스북광고'),
              ),
              ElevatedButton(
                onPressed: _generateRandom,
                child: Text("랜덤숫자나와라"),
              ),
              Text('랜덤숫자 빼애앰~~! : $_random'),
              Column(
                children: <Widget>[_nativeAd()],
              ),
            ],
          )
        ],
      ),
    );
  }
}
