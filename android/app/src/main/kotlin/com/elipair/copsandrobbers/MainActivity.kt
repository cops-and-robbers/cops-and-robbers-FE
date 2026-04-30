package com.elipair.copsandrobbers

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL_NAME = "cops_and_robbers/background_service"
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
}
