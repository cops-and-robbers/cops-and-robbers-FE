package com.elipair.copsandrobbers

import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
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
