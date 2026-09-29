## 1.1.0

* Add `FlutterMute.onRingerModeChanged`, a stream that emits the new `RingerMode` whenever it changes. Android listens for `RINGER_MODE_CHANGED_ACTION`; iOS checks the mute switch once per second while the app is in the foreground.
* Raise the example app's iOS deployment target to 15.0, the minimum Xcode 27 supports. The plugin itself still supports iOS 13.0.

## 1.0.0

First release of `flutter_mute_plus`, forked from [flutter_mute](https://github.com/Alezhka/flutter_mute) 0.0.4.

* **Android**: Support Android Gradle Plugin 8 and 9 (`namespace`, Java/Kotlin 17, compileSdk 36). Fixes [flutter_mute#3](https://github.com/Alezhka/flutter_mute/issues/3), includes [flutter_mute#7](https://github.com/Alezhka/flutter_mute/pull/7).
* **Android**: Fix `openNotificationPolicySettings()` never completing its `Future`.
* **iOS**: Fix `Cannot find 'TARGET_OS_SIMULATOR' in scope` on Xcode 16+. Fixes [flutter_mute#4](https://github.com/Alezhka/flutter_mute/issues/4), includes [flutter_mute#6](https://github.com/Alezhka/flutter_mute/pull/6).
* **iOS**: Add Swift Package Manager support alongside CocoaPods. Fixes [flutter_mute#8](https://github.com/Alezhka/flutter_mute/issues/8), includes [flutter_mute#9](https://github.com/Alezhka/flutter_mute/pull/9).
* **iOS**: Fix `Cannot find 'CACurrentMediaTime' in scope` when building with Swift Package Manager, which flutter_mute#9 still had.
* **iOS**: Rewrite the plugin entry point in pure Swift and add a privacy manifest. Minimum iOS is now 13.0.
* Rename the method channel, Android package and iOS classes so the plugin can coexist with `flutter_mute`.
* Use `defaultTargetPlatform` instead of `dart:io` for platform checks.
* Require Dart 3.
* Fix README examples that referenced a non-existent `setSoundMode()` and a `getRingerMode` getter.
* Add Dart unit tests, an example widget test, an iOS XCTest and an integration test.

## 0.0.4 (flutter_mute)

* Update kotlin version.

## 0.0.3 (flutter_mute)

* Fix crash on IOS Simulator.

## 0.0.2 (flutter_mute)

* Bump to nullsafety.

## 0.0.1 (flutter_mute)

* Implement check/toggle ringer state.
