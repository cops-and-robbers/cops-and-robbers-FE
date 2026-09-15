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

    let adView = NativeAdView()
    let badgeText = label(options["adLabel"] as? String, size: "captionSize", colorKey: "secondaryColor")
    let badge = UIView()
    badge.backgroundColor = color("badgeColor")
    badge.layer.cornerRadius = 4
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
    adView.iconView = icon
    let advertiser = label(nativeAd.advertiser, size: "captionSize", colorKey: "secondaryColor")
    adView.advertiserView = advertiser
    advertiser.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    let header = UIStackView(arrangedSubviews: [badge, icon, advertiser, UIView()])
    header.spacing = 8
    header.alignment = .center
    header.isLayoutMarginsRelativeArrangement = true
    header.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
    header.heightAnchor.constraint(equalToConstant: max(24, number("captionSize") * 1.4)).isActive = true

    let headline = label(nativeAd.headline, size: "headlineSize", colorKey: "textColor", lines: 2, bold: true)
    adView.headlineView = headline
    let body = label(nativeAd.body, size: "bodySize", colorKey: "secondaryColor", lines: 2)
    adView.bodyView = body
    let action = label(nativeAd.callToAction, size: "bodySize", colorKey: "accentColor", bold: true)
    // 클릭 처리는 SDK가 맡는다. Flutter의 게시글 탭과 공유하지 않는다.
    action.isUserInteractionEnabled = false
    adView.callToActionView = action
    let copy = UIStackView(arrangedSubviews: [headline, body, action])
    copy.axis = .vertical
    copy.spacing = 8
    copy.setCustomSpacing(12, after: body)
    let media = MediaView()
    media.mediaContent = nativeAd.mediaContent
    media.contentMode = .scaleAspectFit
    media.widthAnchor.constraint(equalToConstant: 120).isActive = true
    media.heightAnchor.constraint(equalToConstant: 120).isActive = true
    adView.mediaView = media
    let row = UIStackView(arrangedSubviews: [copy, media])
    row.spacing = 12
    row.alignment = .center
    let content = UIStackView(arrangedSubviews: [header, row])
    content.axis = .vertical
    content.spacing = 8
    content.translatesAutoresizingMaskIntoConstraints = false
    adView.addSubview(content)
    NSLayoutConstraint.activate([
      content.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 22),
      content.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -22),
      content.topAnchor.constraint(equalTo: adView.topAnchor, constant: 16),
      content.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -16),
    ])
    adView.nativeAd = nativeAd
    return adView
  }
}
