import Flutter
import UIKit
import GoogleMaps

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

    GeneratedPluginRegistrant.register(with: self)

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
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}