// Enum value names are kept from flutter_mute so migrating only needs an import change.
// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Ringer Mode
enum RingerMode {
  Normal,

  /// Only for Android.
  Silent,

  Vibrate,
}

class FlutterMute {
  @visibleForTesting
  static const MethodChannel channel = MethodChannel('flutter_mute_plus');

  @visibleForTesting
  static const EventChannel ringerModeChangesChannel = EventChannel('flutter_mute_plus/ringer_mode_changes');

  // Shared so every listener rides one native subscription; an EventChannel supports a single native sink.
  static final Stream<RingerMode> _onRingerModeChanged =
      ringerModeChangesChannel.receiveBroadcastStream().map((raw) => RingerMode.values[raw as int]);

  static bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  /// Gets the current device ringer mode.
  ///
  /// On iOS the mute switch is detected by playing a short silent sound, so
  /// only [RingerMode.Normal] or [RingerMode.Vibrate] is returned. The iOS
  /// simulator always returns [RingerMode.Normal].
  static Future<RingerMode> getRingerMode() async {
    final raw = await channel.invokeMethod<int>('getRingerMode');
    return RingerMode.values[raw!];
  }

  /// Emits the new ringer mode whenever it changes.
  ///
  /// Does not emit the current mode on listen; call [getRingerMode] for that.
  ///
  /// On Android changes are pushed by the system. iOS has no change
  /// notification, so the mute switch is checked once per second while the
  /// app is in the foreground. The iOS simulator never emits.
  static Stream<RingerMode> get onRingerModeChanged => _onRingerModeChanged;

  /// Sets the device sound mode. (Only for android)
  ///
  /// Throws [PlatformException] if notification policy access is not granted
  /// on Android 7.0 (API 24) and above. Check
  /// [isNotificationPolicyAccessGranted] and call
  /// [openNotificationPolicySettings] first.
  static Future<void> setRingerMode(RingerMode mode) async {
    if (!_isAndroid) {
      return;
    }

    await channel.invokeMethod<bool>('setRingerMode', {'mode': mode.index});
  }

  /// Gets notification policy access status. Always `true` outside Android.
  static Future<bool> get isNotificationPolicyAccessGranted async {
    if (!_isAndroid) {
      return true;
    }

    final isGranted = await channel.invokeMethod<bool>('isNotificationPolicyAccessGranted');
    return isGranted ?? false;
  }

  /// Opens the notification policy access settings. (Only for android)
  static Future<void> openNotificationPolicySettings() async {
    if (!_isAndroid) {
      return;
    }

    await channel.invokeMethod<void>('openNotificationPolicySettings');
  }
}
