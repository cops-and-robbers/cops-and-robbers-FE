package com.elipair.copsandrobbers

import android.app.Notification
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import androidx.core.app.NotificationCompat

/**
 * 게임 진행 알림(FGS 알림) 한 장을 만들고 다시 게시한다.
 *
 * - [latest]: 서비스가 뜨기 전에 온 현황도 첫 알림에 반영하려고 보관한다.
 * - [dismissedByUser]: 사용자가 닫은 Live Update는 다시 띄우지 않는다(가이드 — 재게시하면 승격 권한을 잃을 수 있음).
 *   닫혀도 FGS·wakelock·위치 추적은 그대로 돈다. 표시만 멈춘다.
 */
object GameSessionNotification {
    const val NOTIFICATION_ID = 1001
    const val CHANNEL_ID = "game_session_channel"

    // 디자인 시스템 팀 강조색 — AppColors.blue(경찰) / AppColors.green(도둑)
    private const val POLICE_ACCENT = 0xFF0088FF.toInt()
    private const val ROBBER_ACCENT = 0xFF38F55B.toInt()

    @Volatile var latest: Map<*, *>? = null
    @Volatile var dismissedByUser = false
    @Volatile var serviceRunning = false

    fun build(context: Context): Notification {
        val status = latest
        val openApp = PendingIntent.getActivity(
            context,
            0,
            Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
            },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val onDismiss = PendingIntent.getBroadcast(
            context,
            0,
            Intent(context, GameSessionNotificationDismissReceiver::class.java),
            PendingIntent.FLAG_IMMUTABLE,
        )

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            // 본문과 같은 앱 언어를 쓰도록 Dart가 넘긴 제목을 우선한다(첫 알림은 리소스).
            .setContentTitle(
                (status?.get("title") as? String)?.takeIf { it.isNotEmpty() }
                    ?: context.getString(R.string.fgs_notification_title),
            )
            .setSmallIcon(R.drawable.ic_stat_notification)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentIntent(openApp)
            .setDeleteIntent(onDismiss)
            // 승격 여부로 동작을 가르지 않는다 — 안 되면 일반 알림으로 보일 뿐이다.
            .setRequestPromotedOngoing(true)

        // 팀 테마: 강조색·팀 표시·팀 캐릭터. Live Updates는 배경 칠하기(colorized)·직접 그린 레이아웃을
        // 막으므로(승격 조건) 시스템 모양 안에서 바꿀 수 있는 것만 쓴다.
        if (status != null) {
            val isRobber = status["isRobberTeam"] as? Boolean ?: false
            builder.setColor(if (isRobber) ROBBER_ACCENT else POLICE_ACCENT)
            (status["teamLabel"] as? String)?.takeIf { it.isNotEmpty() }?.let { builder.setSubText(it) }
            builder.setLargeIcon(
                BitmapFactory.decodeResource(
                    context.resources,
                    if (isRobber) R.drawable.lock_character_robber else R.drawable.lock_character_police,
                ),
            )
        }

        // 상단바 칩에는 이 카운트다운이 나온다(shortCriticalText를 쓰지 않으므로).
        val endAtMs = (status?.get("endAtMs") as? Number)?.toLong()
        if (endAtMs != null) {
            builder.setWhen(endAtMs)
                .setShowWhen(true)
                .setUsesChronometer(true)
                .setChronometerCountDown(true)
        }

        val text = listOfNotNull(
            status?.get("robbersText") as? String,
            status?.get("revealText") as? String,
        ).joinToString(" · ")
        builder.setContentText(
            text.ifEmpty { context.getString(R.string.fgs_notification_text) },
        )
        return builder.build()
    }

    /** 서비스가 떠 있고 사용자가 닫지 않았을 때만 다시 게시한다. */
    fun post(context: Context) {
        if (!serviceRunning || dismissedByUser) return
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(NOTIFICATION_ID, build(context))
    }

    /** 게임이 끝나면 다음 게임에 이전 값·닫힘 상태가 넘어가지 않게 비운다. */
    fun reset() {
        latest = null
        dismissedByUser = false
    }
}
