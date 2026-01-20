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
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}