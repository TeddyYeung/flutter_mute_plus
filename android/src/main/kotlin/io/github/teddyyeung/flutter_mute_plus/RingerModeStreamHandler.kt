package io.github.teddyyeung.flutter_mute_plus

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioManager
import android.os.Build
import io.github.teddyyeung.flutter_mute_plus.domain.AudioManagerService
import io.flutter.plugin.common.EventChannel

class RingerModeStreamHandler(
    private val context: Context,
    private val audioManagerService: AudioManagerService,
) : EventChannel.StreamHandler {

    private var receiver: BroadcastReceiver? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                // RINGER_MODE_CHANGED_ACTION is sticky, so registering replays the last change.
                if (isInitialStickyBroadcast) return
                audioManagerService.getCurrentRingerMode()?.let { events.success(it.index) }
            }
        }
        val filter = IntentFilter(AudioManager.RINGER_MODE_CHANGED_ACTION)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            context.registerReceiver(receiver, filter)
        }
        this.receiver = receiver
    }

    override fun onCancel(arguments: Any?) {
        receiver?.let { context.unregisterReceiver(it) }
        receiver = null
    }
}
