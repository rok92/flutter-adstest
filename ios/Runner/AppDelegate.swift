import UIKit
import Flutter
import FBAudienceNetwork


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var rewardedVideoAd:FBRewardedVideoAd?
    let FBREWARD_CAHNNEL = "com.reward.app/rewarded_ad"
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)
      
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      let modelChannel = FlutterMethodChannel(name: FBREWARD_CAHNNEL, binaryMessenger: controller.binaryMessenger)
      
      modelChannel.setMethodCallHandler(facebookRewardAd)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
}


