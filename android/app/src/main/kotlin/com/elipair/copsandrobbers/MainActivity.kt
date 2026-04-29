package com.elipair.copsandrobbers

import android.content.Intent
import android.os.Build
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
}
