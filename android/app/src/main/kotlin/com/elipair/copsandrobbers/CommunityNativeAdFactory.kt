package com.elipair.copsandrobbers

import android.content.Context
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.text.TextUtils
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.widget.ImageView
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.FlutterInjector
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory

class CommunityNativeAdFactory(private val context: Context) : NativeAdFactory {
    private val fonts = listOf("Medium", "SemiBold").associateWith {
        Typeface.createFromAsset(context.assets, FlutterInjector.instance().flutterLoader()
            .getLookupKeyForAsset("assets/fonts/Pretendard-$it.ttf"))
    }

    private fun dp(value: Number) = (value.toFloat() * context.resources.displayMetrics.density).toInt()

    override fun createNativeAd(nativeAd: NativeAd, customOptions: MutableMap<String, Any>?): NativeAdView {
        val options = requireNotNull(customOptions)
        fun number(key: String) = (options.getValue(key) as Number)
        fun label(value: String?, size: String, color: String, lines: Int = 1, bold: Boolean = false) =
            TextView(context).apply {
                text = value
                setTextSize(TypedValue.COMPLEX_UNIT_DIP, number(size).toFloat())
                setTextColor(number(color).toInt())
                typeface = fonts[if (bold) "SemiBold" else "Medium"]
                maxLines = lines
                ellipsize = TextUtils.TruncateAt.END
                includeFontPadding = false
                visibility = if (value.isNullOrEmpty()) View.GONE else View.VISIBLE
            }

        val adView = NativeAdView(context)
        val content = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(22), dp(16), dp(22), dp(16))
        }
        adView.addView(content, FrameLayout.LayoutParams(-1, -1))
        val header = LinearLayout(context).apply {
            gravity = Gravity.CENTER_VERTICAL
            setPadding(0, 0, dp(20), 0) // SDK AdChoices 영역 확보
        }
        content.addView(header, LinearLayout.LayoutParams(-1, dp(maxOf(24f, number("captionSize").toFloat() * 1.4f))))
        val badge = label(options.getValue("adLabel") as String, "captionSize", "secondaryColor").apply {
            setPadding(dp(4), dp(2), dp(4), dp(2))
            background = GradientDrawable().apply {
                setColor(number("badgeColor").toInt())
                cornerRadius = dp(4).toFloat()
            }
        }
        header.addView(badge)
        val icon = ImageView(context).apply {
            setImageDrawable(nativeAd.icon?.drawable)
            scaleType = ImageView.ScaleType.FIT_CENTER
            visibility = if (nativeAd.icon == null) View.GONE else View.VISIBLE
        }
        header.addView(icon, LinearLayout.LayoutParams(dp(24), dp(24)).apply { leftMargin = dp(8) })
        adView.iconView = icon
        val advertiser = label(nativeAd.advertiser, "captionSize", "secondaryColor")
        header.addView(advertiser, LinearLayout.LayoutParams(0, -2, 1f).apply { leftMargin = dp(8) })
        adView.advertiserView = advertiser

        val row = LinearLayout(context).apply { gravity = Gravity.CENTER_VERTICAL }
        content.addView(row, LinearLayout.LayoutParams(-1, 0, 1f).apply { topMargin = dp(8) })
        val copy = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL }
        row.addView(copy, LinearLayout.LayoutParams(0, -2, 1f).apply { rightMargin = dp(12) })
        val headline = label(nativeAd.headline, "headlineSize", "textColor", 2, true)
        copy.addView(headline)
        adView.headlineView = headline
        val body = label(nativeAd.body, "bodySize", "secondaryColor", 2)
        copy.addView(body, LinearLayout.LayoutParams(-1, -2).apply { topMargin = dp(8) })
        adView.bodyView = body
        val action = label(nativeAd.callToAction, "bodySize", "accentColor", bold = true)
        copy.addView(action, LinearLayout.LayoutParams(-1, -2).apply { topMargin = dp(12) })
        adView.callToActionView = action
        val media = MediaView(context).apply {
            mediaContent = nativeAd.mediaContent
            setImageScaleType(ImageView.ScaleType.CENTER_INSIDE)
        }
        row.addView(media, LinearLayout.LayoutParams(dp(120), dp(120)))
        adView.mediaView = media
        adView.setNativeAd(nativeAd)
        return adView
    }
}
