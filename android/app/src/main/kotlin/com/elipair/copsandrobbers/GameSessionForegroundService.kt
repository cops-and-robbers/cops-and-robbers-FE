package com.elipair.copsandrobbers

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.wifi.WifiManager
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import androidx.core.app.NotificationCompat

/**
 * 게임 진행 중 백그라운드 위치 추적용 Foreground Service.
 *
 * 책임:
 * - 영구 알림 표시 → OS가 프로세스를 foreground priority로 취급
 * - START_STICKY로 OS가 죽여도 재시작
 * - STOMP / 위치 추적 로직은 들고 있지 않음. main isolate에서 그대로 작동.
 *
 * 라이프사이클:
 * - MainActivity의 MethodChannel 핸들러를 통해 startForegroundService / stopService 호출됨
 * - 게임 IN_PROGRESS 동안만 활성
 */
class GameSessionForegroundService : android.app.Service() {

    companion object {
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "game_session_channel"
        private const val CHANNEL_NAME = "게임 진행 중"
    }

    /**
     * CPU deep sleep 방지용 wake lock.
     * Service 라이프사이클(onCreate ~ onDestroy)에 묶여 자동 정리.
     */
    private var wakeLock: PowerManager.WakeLock? = null

    /**
     * WiFi 슬립 방지용 lock.
     * 화면 잠금 시 WiFi가 슬립 모드로 가서 DNS/네트워크가 끊기는 문제 방어.
     */
    private var wifiLock: WifiManager.WifiLock? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        acquireLocks()
    }

    override fun onDestroy() {
        releaseLocks()
        super.onDestroy()
    }

    /**
     * WAKE_LOCK + WIFI_LOCK 획득.
     *
     * - PARTIAL_WAKE_LOCK: CPU만 깨어있게 (화면/입력 영향 없음)
     * - WIFI_MODE_FULL_HIGH_PERF: 화면 꺼져도 WiFi 슬립 차단
     *
     * 둘 다 onDestroy에서 release. timeout 미설정 — 게임 종료 시 service stop이
     * 명시적 정리 시점이라 외부 timeout 불필요.
     */
    private fun acquireLocks() {
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "CopsAndRobbers::GameSession"
        ).apply {
            setReferenceCounted(false)
            acquire()
        }

        val wifiManager =
            applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        wifiLock = wifiManager.createWifiLock(
            WifiManager.WIFI_MODE_FULL_HIGH_PERF,
            "CopsAndRobbers::GameSession::WiFi"
        ).apply {
            setReferenceCounted(false)
            acquire()
        }
    }

    /**
     * 획득한 lock들을 안전하게 release.
     *
     * isHeld 체크로 이중 release 예방. release 실패 시 무시 (이미 끊긴 거라 영향 없음).
     */
    private fun releaseLocks() {
        try {
            if (wakeLock?.isHeld == true) {
                wakeLock?.release()
            }
        } catch (e: Exception) {
            // ignore: already released or invalid state
        }
        try {
            if (wifiLock?.isHeld == true) {
                wifiLock?.release()
            }
        } catch (e: Exception) {
            // ignore
        }
        wakeLock = null
        wifiLock = null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground(NOTIFICATION_ID, buildNotification())
        // OS가 죽여도 재시작 시도
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    /**
     * 알림 채널 생성 (Android 8.0+)
     *
     * IMPORTANCE_LOW: 헤드업 알림 안 뜨고 사운드/진동 없음. 게임 진행 표시용에 적합.
     */
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val channel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "경찰과 도둑 게임 진행 중 표시 알림"
            setShowBadge(false)
        }

        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.createNotificationChannel(channel)
    }

    /**
     * 영구 알림 빌드
     *
     * 알림 탭 시 앱(MainActivity)으로 진입하도록 PendingIntent 연결.
     */
    private fun buildNotification(): Notification {
        val openAppIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            openAppIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("경찰과 도둑")
            .setContentText("게임이 진행 중입니다")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentIntent(pendingIntent)
            .build()
    }
}
