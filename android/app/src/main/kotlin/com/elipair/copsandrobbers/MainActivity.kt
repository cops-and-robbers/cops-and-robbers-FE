package com.elipair.copsandrobbers

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL_NAME = "cops_and_robbers/background_service"
        private const val ICON_CHANNEL_NAME = "cops_and_robbers/app_icon"
        private const val DEFAULT_ALIAS = "app_icon_en"
        private val ICON_ALIASES = listOf("app_icon_en", "app_icon_ko", "app_icon_ja")
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        // Android 15(API 35)부터 SDK 35 타겟 앱에 edge-to-edge 강제 적용.
        // decorView가 시스템 바 inset을 직접 처리하지 않도록 설정 — Play Console 경고 해소.
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        startGameSessionService()
                        result.success(null)
                    }
                    "stop" -> {
                        stopGameSessionService()
                        result.success(null)
                    }
                    "openAppSettings" -> {
                        openAppSettings()
                        result.success(null)
                    }
                    "isIgnoringBatteryOptimizations" -> {
                        result.success(isIgnoringBatteryOptimizations())
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ICON_CHANNEL_NAME)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isSupported" -> result.success(true)
                    "getCurrentIcon" -> result.success(getCurrentIcon())
                    "setIcon" -> {
                        val name = call.argument<String>("name")
                        if (name == null || name !in ICON_ALIASES) {
                            result.error("BAD_ARG", "unknown icon name: $name", null)
                        } else {
                            setIcon(name)
                            result.success(null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun startGameSessionService() {
        val intent = Intent(this, GameSessionForegroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Android 8.0+: startForegroundService 필수. 5초 이내 startForeground 호출 안 하면 ANR.
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun stopGameSessionService() {
        val intent = Intent(this, GameSessionForegroundService::class.java)
        stopService(intent)
    }

    /**
     * 앱 상세 설정 화면 열기 (사용자 명시적 [설정 열기] 탭에 의해서만 호출).
     *
     * 설정 → 앱 → 경찰과 도둑 으로 이동.
     * 거기서 사용자가 "배터리" 메뉴 → "제한 없음" 선택.
     *
     * App Store Guideline 5.1.1(iv) 정책: 사용자 명시적 탭으로 호출이므로
     * 자동 리다이렉트 금지 정책에 해당하지 않음.
     */
    private fun openAppSettings() {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            data = Uri.fromParts("package", packageName, null)
            // Activity context가 아닌 곳에서 호출될 수 있으므로 NEW_TASK 플래그 필수
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(intent)
    }

    /**
     * 배터리 최적화 무시 권한 보유 여부 체크.
     *
     * Samsung "제한 없음" 설정이 이 API에 매핑됨.
     * 일부 OEM에서 false negative 가능성 있음(매우 드묾).
     *
     * API 23 (Android 6.0, M) 미만은 이 API 자체가 없음.
     * 그 이전 버전은 배터리 최적화 정책이 없었으므로 true 반환(통과).
     */
    private fun isIgnoringBatteryOptimizations(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return true
        }
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        return powerManager.isIgnoringBatteryOptimizations(packageName)
    }

    // alias는 단순 접미사("app_icon_en" 등)여야 한다 — 패키지명이 자동 접두된다.
    // (완전한 클래스명을 넣으면 이중 접두어가 됨. ICON_ALIASES 상수로만 유지)
    private fun aliasComponent(alias: String): ComponentName =
        ComponentName(packageName, "$packageName.$alias")

    /**
     * 현재 enabled 상태인 alias 이름 반환.
     *
     * 설치 직후 기본 enabled alias(app_icon_en)는 ENABLED가 아니라
     * COMPONENT_ENABLED_STATE_DEFAULT로 보고될 수 있다. 따라서 명시적 ENABLED가
     * 하나도 없으면 manifest 기본값(=DEFAULT_ALIAS)을 반환한다.
     */
    private fun getCurrentIcon(): String {
        val pm = packageManager
        for (alias in ICON_ALIASES) {
            if (pm.getComponentEnabledSetting(aliasComponent(alias)) ==
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            ) {
                return alias
            }
        }
        return DEFAULT_ALIAS
    }

    /**
     * 타깃 alias를 enable한 뒤 나머지를 disable한다.
     *
     * enable-우선 순서 + DONT_KILL_APP: 활성 런처 컴포넌트가 한 순간도 0개가 되지
     * 않게 하여 런처 아이콘 소실/프로세스 종료를 최소화한다.
     */
    private fun setIcon(target: String) {
        val pm = packageManager
        pm.setComponentEnabledSetting(
            aliasComponent(target),
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP,
        )
        for (alias in ICON_ALIASES) {
            if (alias == target) continue
            pm.setComponentEnabledSetting(
                aliasComponent(alias),
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP,
            )
        }
    }
}
