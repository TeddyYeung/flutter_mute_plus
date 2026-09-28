package io.github.teddyyeung.flutter_mute_plus

import android.app.NotificationManager
import android.content.Context
import android.content.Context.NOTIFICATION_SERVICE
import android.media.AudioManager
import io.github.teddyyeung.flutter_mute_plus.data.AudioManagerServiceImpl
import io.github.teddyyeung.flutter_mute_plus.data.IntentManagerServiceImpl
import io.github.teddyyeung.flutter_mute_plus.domain.AudioManagerService
import io.github.teddyyeung.flutter_mute_plus.domain.IntentManagerService
import io.github.teddyyeung.flutter_mute_plus.entities.RingerMode
import io.github.teddyyeung.flutter_mute_plus.utils.ErrorUtil
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterMutePlusPlugin */
class FlutterMutePlusPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var context: Context? = null
  private var audioManagerService: AudioManagerService? = null
  private var intentManagerService: IntentManagerService? = null

  private val isAccessGranted
    get() = intentManagerService?.isAccessGranted() ?: false

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val context = flutterPluginBinding.applicationContext
    val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    audioManagerService = AudioManagerServiceImpl(audioManager)

    val notificationManager = context.getSystemService(NOTIFICATION_SERVICE) as NotificationManager
    intentManagerService = IntentManagerServiceImpl(notificationManager)

    this.context = context

    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_mute_plus")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getRingerMode" -> {
        getCurrentRingerMode(result)
      }
      "setRingerMode" -> {
        val raw = call.argument<Int>("mode") ?: RingerMode.NORMAL.index
        val mode = RingerMode.entries[raw]
        setCurrentRingerMode(result, mode)
      }
      "openNotificationPolicySettings" -> {
        intentManagerService?.launchSettings(context!!)
        result.success(null)
      }
      "isNotificationPolicyAccessGranted" -> {
        getPermissionStatus(result)
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    audioManagerService = null
    intentManagerService = null
    context = null
  }

  private fun setCurrentRingerMode(result: Result, ringerMode: RingerMode) {
    if (!isAccessGranted) {
      result.error(
              ErrorUtil.InvalidPermission.errorCode,
              ErrorUtil.InvalidPermission.errorMessage,
              ErrorUtil.InvalidPermission.errorDetails
      )
      return
    }
    audioManagerService?.setRingerMode(ringerMode)
    result.success(true)
  }

  private fun getCurrentRingerMode(result: Result) {
    val ringerMode = audioManagerService?.getCurrentRingerMode()
    if (ringerMode == null) {
      result.error(
              ErrorUtil.ServiceUnavailable.errorCode,
              ErrorUtil.ServiceUnavailable.errorMessage,
              ErrorUtil.ServiceUnavailable.errorDetails
      )
      return
    }
    result.success(ringerMode.index)
  }

  private fun getPermissionStatus(result: Result) {
    result.success(isAccessGranted)
  }
}
