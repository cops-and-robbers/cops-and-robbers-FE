import Flutter
import UIKit
import GoogleMaps
import google_mobile_ads

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let apiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String ?? ""

    if !apiKey.isEmpty {
      GMSServices.provideAPIKey(apiKey)
    }

    #if DEBUG
    if apiKey.isEmpty {
      print("⚠️ GOOGLE_MAPS_API_KEY가 비어 있습니다. Secrets.xcconfig 설정을 확인하세요.")
    }
    #endif

    // 진행 중인 Activity는 보존한다. 게임 복원 후 update가 같은 라운드를 이어받는다.
    if #available(iOS 16.2, *) {
      MainActor.assumeIsolated { GameStatusActivityManager.shared.restore() }
    }

    GeneratedPluginRegistrant.register(with: self)

    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
      self, factoryId: "communityNative", nativeAdFactory: CommunityNativeAdFactory()
    )

    // 로케일 기반 동적 앱 아이콘 — Android와 동일 채널(cops_and_robbers/app_icon)을 공유한다.
    // Primary(영어)는 식별자 "app_icon_en"으로 주고받고, iOS에선 nil(Primary)로 매핑한다.
    if let controller = window?.rootViewController as? FlutterViewController {
      let iconChannel = FlutterMethodChannel(
        name: "cops_and_robbers/app_icon",
        binaryMessenger: controller.binaryMessenger
      )
      iconChannel.setMethodCallHandler { call, result in
        switch call.method {
        case "isSupported":
          result(UIApplication.shared.supportsAlternateIcons)
        case "getCurrentIcon":
          // nil(Primary) → "app_icon_en" (Android alias 식별자와 일치)
          result(UIApplication.shared.alternateIconName ?? "app_icon_en")
        case "setIcon":
          let name = (call.arguments as? [String: Any])?["name"] as? String
          // "app_icon_en"은 Primary → nil. 그 외(app_icon_ko/ja)는 alternate 이름 그대로.
          let target: String? = (name == nil || name == "app_icon_en") ? nil : name
          UIApplication.shared.setAlternateIconName(target) { error in
            if let error = error {
              result(FlutterError(
                code: "SET_ICON_FAILED",
                message: error.localizedDescription,
                details: nil
              ))
            } else {
              result(nil)
            }
          }
        default:
          result(FlutterMethodNotImplemented)
        }
      }

      // 게임 진행 인프라 — Android와 같은 채널. iOS는 백그라운드 위치를 OS가 처리하므로
      // start는 할 일이 없고, 잠금 화면 현황(Live Activity)만 update/stop으로 다룬다.
      let backgroundChannel = FlutterMethodChannel(
        name: "cops_and_robbers/background_service",
        binaryMessenger: controller.binaryMessenger
      )
      backgroundChannel.setMethodCallHandler { call, result in
        guard #available(iOS 16.2, *) else {
          result(nil)
          return
        }
        switch call.method {
        case "start":
          result(nil)
        case "update":
          guard let args = call.arguments as? [String: Any],
                let endAtMs = (args["endAtMs"] as? NSNumber)?.doubleValue,
                let gameId = (args["gameId"] as? NSNumber)?.intValue, gameId > 0 else {
            result(nil)
            return
          }
          func date(_ key: String) -> Date? {
            (args[key] as? NSNumber).map { Date(timeIntervalSince1970: $0.doubleValue / 1000) }
          }
          let attributes = GameStatusAttributes(
            title: args["title"] as? String ?? "",
            remainingTimeLabel: args["remainingTimeLabel"] as? String ?? "",
            remainingRobbersLabel: args["remainingRobbersLabel"] as? String ?? "",
            locationRevealLabel: args["locationRevealLabel"] as? String ?? "",
            gameOverLabel: args["gameOverLabel"] as? String ?? "",
            isRobberTeam: args["isRobberTeam"] as? Bool ?? false,
            teamLabel: args["teamLabel"] as? String ?? "",
            localeCode: args["localeCode"] as? String ?? "en",
            gameId: gameId
          )
          let endAt = Date(timeIntervalSince1970: endAtMs / 1000)
          let state = GameStatusAttributes.ContentState(
            startAt: date("startAtMs") ?? endAt,
            endAt: endAt,
            nextRevealAt: date("nextRevealAtMs"),
            aliveRobbers: (args["aliveRobbers"] as? NSNumber)?.intValue,
            totalRobbers: (args["totalRobbers"] as? NSNumber)?.intValue
          )
          // 채널 핸들러는 메인 스레드에서 불린다. Task로 예약하면 update·stop의 실행 순서가 보장되지 않아
          // stop 뒤에 늦게 돈 update가 끝난 게임의 Live Activity를 다시 만들 수 있다 — 그 자리에서 실행한다.
          MainActor.assumeIsolated {
            GameStatusActivityManager.shared.update(attributes: attributes, state: state)
          }
          result(nil)
        case "stop":
          MainActor.assumeIsolated { GameStatusActivityManager.shared.stop() }
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
