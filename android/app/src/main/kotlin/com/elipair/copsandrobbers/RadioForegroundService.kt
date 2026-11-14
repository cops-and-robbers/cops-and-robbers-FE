package com.elipair.copsandrobbers

import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat

/**
 * 경찰 팀 무전(#697) 중 화면이 꺼져도 마이크·소리를 유지하는 Foreground Service.
 *
 * 위치 서비스와 합치지 않는다 — 마이크를 거부한 경찰의 서비스가 못 떠서 위치 추적까지 멈추면 안 된다.
 * microphone 타입은 백그라운드 시작이 거절되므로(Android 14+) 앱이 화면에 있을 때만 시작한다.
 */
class RadioForegroundService : android.app.Service() {

    companion object {
        private const val NOTIFICATION_ID = 7002
        private const val TAG = "RadioFGS"
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        GameSessionNotification.ensureChannel(this)
        val notification = NotificationCompat.Builder(this, GameSessionNotification.CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_notification)
            .setContentTitle(getString(R.string.fgs_notification_title))
            .setContentText(getString(R.string.radio_notification_text))
            .setOngoing(true)
            .setSilent(true)
            .build()
        try {
            val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE
            } else {
                0
            }
            ServiceCompat.startForeground(this, NOTIFICATION_ID, notification, type)
        } catch (e: Exception) {
            // 권한이 없거나 백그라운드에서 불린 경우 — 무전만 포기하고 앱은 살린다
            Log.w(TAG, "무전 포그라운드 서비스 시작 실패", e)
            stopSelf()
        }
        // 위치 서비스와 같은 이유로 단독 부활시키지 않는다
        return START_NOT_STICKY
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        stopSelf()
        super.onTaskRemoved(rootIntent)
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
