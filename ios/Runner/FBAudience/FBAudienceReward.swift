//
//  FBAudienceReward.swift
//  Runner
//
//  Created by 곽경록 on 1/24/24.
//

import Foundation
import Flutter
import FBAudienceNetwork
import AdSupport


enum Method: String {
    case GENERATE = "generate"
    case LOADREWARD = "loadRewardedAd"
    case SHOWREWARD = "showRewardedAd"
    case ADCLOSED = "rewardedVideoAdDidClose"
}

let rewardLoad = FBRewardedAd()
//let rewardShow = FBRewardShow()

var rewardedVideoAd: FBRewardedVideoAd?


func facebookRewardAd(_ call: FlutterMethodCall, result: @escaping FlutterResult){
    let mode = Method(rawValue: call.method)
    switch mode {
    case .GENERATE:
        rewardLoad.generate(call, result)
    case .LOADREWARD:
        rewardLoad.loadRewardedAd(call.arguments as! String)
    case .SHOWREWARD:
        rewardLoad.showRewardedAd()
    case .ADCLOSED:
        rewardLoad.rewardedVideoAdDidClose(rewardedVideoAd!, call, result)
    default:
        result(FlutterMethodNotImplemented)
            return
    }
}

class FBRewardedAd: NSObject, FBRewardedVideoAdDelegate {
    
    var rewardedVideoAd:FBRewardedVideoAd?
    
    override init() {
        print(ASIdentifierManager.shared().advertisingIdentifier.uuidString)
        print("FBRewardedAd init")
    }
    
    func rewardedVideoAdDidLoad(_ rewardedVideoAd: FBRewardedVideoAd) {
      print("Video ad is loaded and ready to be displayed")
    }

    func rewardedVideoAd(_ rewardedVideoAd: FBRewardedVideoAd, didFailWithError error: Error) {
      print("Rewarded video ad failed to load")
        print(error)
    }

    func rewardedVideoAdDidClick(_ rewardedVideoAd: FBRewardedVideoAd) {
      print("Video ad clicked")
    }

    func rewardedVideoAdDidClose(_ rewardedVideoAd: FBRewardedVideoAd, _ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
      print("Rewarded Video ad closed - this can be triggered by closing the application, or closing the video end card")
      let facebookAdClose = ((call.arguments as? Dictionary<String, Any>)?["range"] as? String ?? "DID_CLOSED")
      result(["close": facebookAdClose]);
    }

    func rewardedVideoAdVideoComplete(_ rewardedVideoAd: FBRewardedVideoAd) {
      print("Rewarded Video ad video completed - this is called after a full video view, before the ad end card is shown. You can use this event to initialize your reward")
    }
    
    func loadRewardedAd(_ arguments: String){
        
//        print("Facebook Video Ads Load Click :: \(arguments)")
        self.rewardedVideoAd = FBRewardedVideoAd(placementID: arguments)
        self.rewardedVideoAd!.delegate = self
        self.rewardedVideoAd!.load()
    }
    
    func showRewardedAd() -> Bool{
        guard let rewardedVideoAd = rewardedVideoAd, rewardedVideoAd.isAdValid else {
          return false
        }
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
          return false
        }
        func show() {
          rewardedVideoAd.show(fromRootViewController: rootViewController)
        }
        if(rewardedVideoAd.isAdValid == true){
            show()
        }
        return true
    }
    
    func generate(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
     let userRange = ((call.arguments as? Dictionary<String, Any>)?["range"] as? Int ?? 45)

     if userRange > 45 {
      result(FlutterError(code: "Out of range", message: "Currently we dont support > 100", details: nil))
     } else {
      let ranNum = Int.random(in: 1...userRange)
      result(["ran": ranNum, "rangeStart": 1, "rangeEnd": userRange])
      }
    }
}
