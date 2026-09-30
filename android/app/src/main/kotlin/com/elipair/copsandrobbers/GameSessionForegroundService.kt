package com.elipair.copsandrobbers

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.os.PowerManager

/**
 * 게임 진행 중 백그라운드 위치 추적용 Foreground Service.
 *
 * 책임:
 * - 영구 알림 표시 → OS가 프로세스를 foreground priority로 취급
 * - START_NOT_STICKY — FGS 단독 부활은 무의미하여 재시작 안 함 (onStartCommand 주석 참조)
 * - STOMP / 위치 추적 로직은 들고 있지 않음. main isolate에서 그대로 작동.
 *
 * 라이프사이클:
 * - MainActivity의 MethodChannel 핸들러를 통해 startForegroundService / stopService 호출됨
 * - 게임 IN_PROGRESS 동안만 활성
 */
class GameSessionForegroundService : android.app.Service() {

    companion object {
        // 누수 가드: release 누락(프로세스 비정상 종료 등) 시에도 OS가 자동 해제.
        // 게임 최대 길이보다 넉넉한 값.
        private const val WAKELOCK_TIMEOUT_MS = 4 * 60 * 60 * 1000L
    }

    private var wakeLock: PowerManager.WakeLock? = null

    override fun onCreate() {
        super.onCreate()
        // 이전 게임 종료 직전에 닫은 알림의 delete 브로드캐스트가 reset()·onDestroy 뒤에 늦게 오면
        // 닫힘 표시가 남아 이번 게임 내내 갱신이 막힌다 — 새 게임 서비스가 뜰 때 한 번 더 끈다.
        GameSessionNotification.dismissedByUser = false
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        GameSessionNotification.serviceRunning = true
        startForeground(
            GameSessionNotification.NOTIFICATION_ID,
            GameSessionNotification.build(this),
        )
        // FGS는 프로세스를 살려두지만 CPU를 깨워두진 않는다.
        // 화면이 꺼지면 main isolate의 Dart 타이머(STOMP 하트비트 10초)가 멈춰
        // 서버가 연결을 끊으므로, 세션 동안 partial wakelock으로 CPU를 유지한다.
        // (내비 앱과 동일한 FGS(location) + PARTIAL_WAKE_LOCK 레시피)
        acquireWakeLock()
        // START_NOT_STICKY 사용 이유:
        // - FGS는 메인 앱 프로세스에서 동작 (별도 process 미지정)
        // - OS가 메모리 부족으로 FGS를 죽일 땐 앱 프로세스도 함께 사망
        // - START_STICKY로 FGS만 부활시켜도 Flutter측이 죽은 상태라
        //   STOMP/위치 추적이 동작하지 않아 "게임 진행 중" 알림만 거짓으로 남음
        // - FGS 단독 부활은 기능적으로 무의미하므로 START_NOT_STICKY로 명시
        return START_NOT_STICKY
    }

    private fun acquireWakeLock() {
        if (wakeLock?.isHeld == true) return
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "copsandrobbers:game_session",
        ).apply {
            // start 중복 호출돼도 release 1회로 확실히 해제되도록
            setReferenceCounted(false)
            acquire(WAKELOCK_TIMEOUT_MS)
        }
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        // 태스크 스와이프 시 Flutter 엔진이 죽어 MethodChannel stop을 호출할 주체가 없다.
        // FGS+wakelock이 고아로 남지 않도록 직접 종료 → onDestroy에서 wakelock 해제.
        stopSelf()
        super.onTaskRemoved(rootIntent)
    }

    override fun onDestroy() {
        wakeLock?.let { if (it.isHeld) it.release() }
        wakeLock = null
        GameSessionNotification.serviceRunning = false
        GameSessionNotification.reset()
        super.onDestroy()
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
            GameSessionNotification.CHANNEL_ID,
            getString(R.string.fgs_channel_name),
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = getString(R.string.fgs_channel_description)
            setShowBadge(false)
        }

        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.createNotificationChannel(channel)
    }
}
