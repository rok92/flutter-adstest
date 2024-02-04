import 'dart:io';

import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class AdManager {
  static String get getPlacementId {
    if (Platform.isAndroid) {
      return "Rewarded_Android";
    } else if (Platform.isIOS) {
      return "Rewarded_iOS";
    }
    return "";
  }

  static String get getGameId {
    if(Platform.isAndroid){
      return "5534321";
    }else if(Platform.isIOS){
      return "5534320";
    }
    return "";
  }

  static Future<void> loadUnityAd() async {

    await UnityAds.load(
      placementId: getPlacementId,
      onComplete: (placementId) {
        //print("Load Complete $placementId");
      },
      onFailed: (placementId, error, message) =>
          print('Load Failed $placementId: $error $message'),
    );
  }

  static Future<void> showRwAd() async {
    UnityAds.showVideoAd(
      placementId: getPlacementId,
      serverId: getGameId,
      onComplete: (placementId) async {
        // await loadUnityAd();
        print('Video Ad $placementId, $getGameId completed');
      },
      onFailed: (placementId, error, message) {
        print('Video Ad $placementId failed: $error $message');
      },
      onStart: (placementId) => print('Video Ad $placementId started'),
      onClick: (placementId) => print('Video Ad $placementId click'),
      onSkipped: (placementId) {
        print('Video Ad $placementId skipped');
      },
    );
  }
}
