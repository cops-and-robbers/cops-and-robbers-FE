import CoreText
import Flutter
import GoogleMobileAds
import UIKit
import google_mobile_ads

final class CommunityNativeAdFactory: NSObject, FLTNativeAdFactory {
  private static let registerFonts: Void = {
    for weight in ["Medium", "SemiBold"] {
      let key = FlutterDartProject.lookupKey(forAsset: "assets/fonts/Pretendard-\(weight).ttf")
      if let path = Bundle.main.path(forResource: key, ofType: nil) {
        CTFontManagerRegisterFontsForURL(URL(fileURLWithPath: path) as CFURL, .process, nil)
      }
    }
  }()

  func createNativeAd(_ nativeAd: NativeAd, customOptions: [AnyHashable: Any]? = nil) -> NativeAdView? {
    guard let options = customOptions else { return nil }
    _ = Self.registerFonts
    func number(_ key: String) -> CGFloat { CGFloat((options[key] as? NSNumber)?.doubleValue ?? 0) }
    func color(_ key: String) -> UIColor {
      let value = (options[key] as? NSNumber)?.uint32Value ?? 0
      return UIColor(red: CGFloat((value >> 16) & 255) / 255,
                     green: CGFloat((value >> 8) & 255) / 255,
                     blue: CGFloat(value & 255) / 255, alpha: CGFloat(value >> 24) / 255)
    }
    func label(_ text: String?, size: String, colorKey: String, lines: Int = 1, bold: Bool = false) -> UILabel {
      let label = UILabel()
      label.text = text
      label.font = UIFont(name: bold ? "Pretendard-SemiBold" : "Pretendard-Medium", size: number(size))
        ?? UIFont.systemFont(ofSize: number(size), weight: bold ? .semibold : .medium)
      label.textColor = color(colorKey)
      label.numberOfLines = lines
      label.lineBreakMode = .byTruncatingTail
      label.isHidden = text?.isEmpty ?? true
      return label
    }

    // SDK 등록 전에 Flutter 슬롯 크기로 자산 배치를 완료한다.
    let frame = CGRect(x: 0, y: 0, width: number("width"), height: number("height"))
    let adView = NativeAdView(frame: frame)
    let badgeText = label(options["adLabel"] as? String, size: "captionSize", colorKey: "secondaryColor")
    let badge = UIView()
    badge.backgroundColor = color("badgeColor")
    badge.layer.cornerRadius = 4
    badgeText.setContentCompressionResistancePriority(.required, for: .horizontal)
    badgeText.setContentHuggingPriority(.required, for: .horizontal)
    badgeText.translatesAutoresizingMaskIntoConstraints = false
    badge.addSubview(badgeText)
    NSLayoutConstraint.activate([
      badgeText.leadingAnchor.constraint(equalTo: badge.leadingAnchor, constant: 4),
      badgeText.trailingAnchor.constraint(equalTo: badge.trailingAnchor, constant: -4),
      badgeText.topAnchor.constraint(equalTo: badge.topAnchor, constant: 2),
      badgeText.bottomAnchor.constraint(equalTo: badge.bottomAnchor, constant: -2),
    ])
    let icon = UIImageView(image: nativeAd.icon?.image)
    icon.contentMode = .scaleAspectFit
    icon.isHidden = nativeAd.icon == nil
    icon.widthAnchor.constraint(equalToConstant: 24).isActive = true
    icon.heightAnchor.constraint(equalToConstant: 24).isActive = true
    adView.iconView = icon.isHidden ? nil : icon
    let advertiser = label(nativeAd.advertiser, size: "captionSize", colorKey: "secondaryColor")
    adView.advertiserView = advertiser.isHidden ? nil : advertiser
    advertiser.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    let headline = label(nativeAd.headline, size: "headlineSize", colorKey: "textColor", bold: true)
    adView.headlineView = headline
    headline.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    let header = UIStackView(arrangedSubviews: [badge, headline])
    header.spacing = 8
    header.alignment = .center
    let body = label(nativeAd.body, size: "bodySize", colorKey: "secondaryColor")
    adView.bodyView = body.isHidden ? nil : body
    let action = label(nativeAd.callToAction, size: "bodySize", colorKey: "accentColor", bold: true)
    // 클릭 처리는 SDK가 맡는다. Flutter의 게시글 탭과 공유하지 않는다.
    action.isUserInteractionEnabled = false
    adView.callToActionView = action.isHidden ? nil : action
    let metadata = UIStackView(arrangedSubviews: [advertiser, action])
    metadata.spacing = 8
    metadata.distribution = .fillEqually
    metadata.alignment = .center
    let footer = UIStackView(arrangedSubviews: [icon, metadata])
    footer.spacing = 8
    footer.alignment = .center
    let copy = UIStackView(arrangedSubviews: [header, body, footer])
    copy.axis = .vertical
    copy.spacing = 4
    let media = MediaView()
    media.mediaContent = nativeAd.mediaContent
    media.contentMode = .scaleAspectFit
    media.widthAnchor.constraint(equalToConstant: 120).isActive = true
    media.heightAnchor.constraint(equalToConstant: 120).isActive = true
    adView.mediaView = media
    let content = UIStackView(arrangedSubviews: [copy, media])
    content.spacing = 12
    content.alignment = .center
    content.translatesAutoresizingMaskIntoConstraints = false
    adView.addSubview(content)
    NSLayoutConstraint.activate([
      content.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 22),
      content.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -22),
      content.topAnchor.constraint(equalTo: adView.topAnchor, constant: 1),
      content.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -1),
    ])
    adView.layoutIfNeeded()
    adView.nativeAd = nativeAd
    return adView
  }
}
