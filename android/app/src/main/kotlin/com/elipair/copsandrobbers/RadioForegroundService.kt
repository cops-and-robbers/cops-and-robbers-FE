package com.elipair.copsandrobbers

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
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
 * 위치용 [GameSessionForegroundService]와 합치지 않는다 — 한 서비스에 microphone 타입을 같이
 * 넣으면 마이크를 거부한 경찰은 서비스가 못 떠서 위치 추적까지 멈춘다. 무전은 부가 기능이라
 * 게임 본체(위치)를 죽이지 않게 따로 띄운다.
 *
 * microphone 타입은 백그라운드에서 시작하면 Android 14+에서 SecurityException이 나므로,
 * Flutter 쪽은 앱이 화면에 있고 마이크 권한을 받은 뒤에만 start를 부른다.
 */
class RadioForegroundService : android.app.Service() {

    companion object {
        private const val NOTIFICATION_ID = 7002
        private const val TAG = "RadioFGS"
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        ensureChannel()
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

    // 게임 알림과 같은 채널을 쓴다 — 보통 위치 서비스가 먼저 만들지만 순서를 믿지 않는다
    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (manager.getNotificationChannel(GameSessionNotification.CHANNEL_ID) != null) return
        manager.createNotificationChannel(
            NotificationChannel(
                GameSessionNotification.CHANNEL_ID,
                getString(R.string.fgs_channel_name),
                NotificationManager.IMPORTANCE_LOW,
            ).apply {
                description = getString(R.string.fgs_channel_description)
                setShowBadge(false)
            },
        )
    }
}
