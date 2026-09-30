package com.elipair.copsandrobbers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** 사용자가 게임 진행 알림을 닫으면 이번 게임 동안 다시 게시하지 않는다. */
class GameSessionNotificationDismissReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        GameSessionNotification.dismissedByUser = true
    }
}
