package io.github.teddyyeung.flutter_mute_plus.domain

import android.content.Context

interface IntentManagerService {

    fun isAccessGranted(): Boolean

    fun launchSettings(context: Context)

}