import 'package:flutter/services.dart';

class FBRewardedAd {
  static const FBREWARD_CAHNNEL = "com.reward.app/rewarded_ad";
  // static const METHOD_LOAD = "loadRw";

  final MethodChannel channel = const MethodChannel(FBREWARD_CAHNNEL);


  Future<int?> generate([int? userRange]) async {
    try {
      final result = await channel.invokeMethod("generate", <String, dynamic>{
        'range': userRange,
      });
      final res = result as Map;
      print(res);
      return res["ran"];
    } catch(e) {
      print("generate exception: $e");
      rethrow;
    }
  }

  Future<String?> rewardedVideoAdDidClose([String? facebookAdClose]) async {
    try {
      final result = await channel.invokeMethod("rewardedVideoAdDidClose", <String, dynamic>{
        'range': facebookAdClose,
      });
      final res = result as Map;
      print(res);
      return res["close"];
    } catch(e) {
      print("generate exception: $e");
      rethrow;
    }
  }

  Future<void> loadRewardedVideoAd(String? placementID) async {
    await channel.invokeMethod('loadRewardedAd', placementID);
  }

  Future<void> showRewardedAd() async {
    await channel.invokeMethod("showRewardedAd");
  }
}
