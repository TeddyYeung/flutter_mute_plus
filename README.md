# flutter_mute_plus

[![pub package](https://img.shields.io/pub/v/flutter_mute_plus.svg)](https://pub.dev/packages/flutter_mute_plus)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

A Flutter plugin to check or toggle the device ringer mode.

A maintained fork of [flutter_mute](https://github.com/Alezhka/flutter_mute) by Aleksei Sturov. The Dart API is the same, so switching takes one import change, and the plugin builds with current Android Gradle Plugin, Xcode and Flutter versions.

## Why switch from flutter_mute

`flutter_mute` 0.0.4, published in December 2021, is its last release, and its repository has had no commits since. The maintainer has not responded to any issue or pull request opened after 2021. With current toolchains the package now:

- **fails to build on Android** with Android Gradle Plugin 8 and later,
- **fails to compile on iOS** with Xcode 16 and later,
- **triggers a Flutter warning** for missing Swift Package Manager support, which Flutter says will become an error.

Several people submitted fixes as pull requests, but none were merged. `flutter_mute_plus` merges those fixes, adds the ones that were still missing, and publishes the result as a versioned package on pub.dev.

## What flutter_mute_plus adds

| | flutter_mute 0.0.4 | flutter_mute_plus 1.0.0 |
|---|:---:|:---:|
| Android Gradle Plugin 8 / 9 | ❌ build fails | ✅ |
| Xcode 16+ | ❌ compile error | ✅ |
| Swift Package Manager | ❌ | ✅ (CocoaPods still supported) |
| iOS privacy manifest | ❌ | ✅ |
| `openNotificationPolicySettings()` completes | ❌ never returns | ✅ |
| Can be installed next to `flutter_mute` | — | ✅ separate channel and class names |
| Unit and integration tests | ❌ | ✅ |
| Dart API | `FlutterMute`, `RingerMode` | unchanged |

## What was fixed, and how it was verified

Every open problem in the upstream repository is fixed here. Each fix was checked with Flutter 3.44.9 and Xcode 27.2.

| Fix | Upstream | Verified |
|---|---|---|
| **Android builds on AGP 8 and 9.** The build script moves to Kotlin DSL with `namespace`, Java/Kotlin 17 and compileSdk 36. Upstream PR #7 only added `namespace` and kept the AGP 3.5 / Gradle 5.6 scripts. | [#3](https://github.com/Alezhka/flutter_mute/issues/3), [PR #7](https://github.com/Alezhka/flutter_mute/pull/7) | ✅ Example APK builds on AGP 8.9.1 (Gradle 8.11.1) and AGP 9.0.1 (Gradle 9.1) |
| **iOS compiles on Xcode 16+.** `TARGET_OS_SIMULATOR` is replaced with `#if targetEnvironment(simulator)`. | [#4](https://github.com/Alezhka/flutter_mute/issues/4), [PR #6](https://github.com/Alezhka/flutter_mute/pull/6) | ✅ iOS simulator build succeeds; `getRingerMode()` returns on the simulator (integration test) |
| **Swift Package Manager support.** Adds `Package.swift` and loads resources via `Bundle.module`. | [#8](https://github.com/Alezhka/flutter_mute/issues/8), [PR #9](https://github.com/Alezhka/flutter_mute/pull/9) | ✅ SPM build succeeds; integration test passes on an iOS 18 simulator |
| **SPM compile error in PR #9.** `Cannot find 'CACurrentMediaTime' in scope` under SPM, because `QuartzCore` was not imported. | Found in this fork | ✅ SPM build succeeds |
| **CocoaPods still works.** The `.podspec` is kept next to `Package.swift`. | — | ✅ CocoaPods build succeeds; `mute.aiff` bundled |
| **`openNotificationPolicySettings()` completes.** The Android side never sent a result, so `await` never returned. | Found in this fork | ✅ Dart unit test |
| **Installs next to `flutter_mute`.** The method channel, Android package and iOS classes are renamed. | — | ✅ Dart unit test |
| **Correct README examples.** Upstream showed `getRingerMode` as a getter and a `setSoundMode()` method, which does not exist. | Found in this fork | ✅ Examples match the API |

`flutter analyze` reports no issues, and Dart unit tests cover every method channel call on Android and iOS.

**Not verified yet:** mute switch detection on a physical iPhone. The simulator skips that code path. The detection logic itself is unchanged from `flutter_mute`. Please [open an issue](https://github.com/TeddyYeung/flutter_mute_plus/issues) if its behavior differs.

## Migrating from flutter_mute

The Dart API is unchanged. Replace the dependency and the import:

```diff
 dependencies:
-  flutter_mute: ^0.0.4
+  flutter_mute_plus: ^1.1.0
```

```diff
-import 'package:flutter_mute/flutter_mute.dart';
+import 'package:flutter_mute_plus/flutter_mute_plus.dart';
```

If you depended on a git fork of `flutter_mute` to work around the issues above, you can remove it.

Minimum versions: Dart 3, iOS 13.0, Android minSdk 21.

## Features

1. Detect the device's current ringer mode.
2. Listen for ringer mode changes.
3. Switch between Normal, Silent and Vibrate (Android only).
4. Check and request notification policy access, which Android 7.0 (API 24) and above require before the ringer mode can change.

| Mode | Description |
|---|---|
| `RingerMode.Normal` | Normal mode |
| `RingerMode.Silent` | Silent mode (Android only) |
| `RingerMode.Vibrate` | Vibrate mode. On iOS, returned when the mute switch is on |

## Usage

Get the current ringer mode:

```dart
import 'package:flutter_mute_plus/flutter_mute_plus.dart';

final RingerMode mode = await FlutterMute.getRingerMode();
```

Listen for changes. The stream emits only when the mode changes, so call `getRingerMode()` for the starting value:

```dart
final subscription = FlutterMute.onRingerModeChanged.listen((RingerMode mode) {
  print('Ringer mode changed to $mode');
});

// Cancel when you no longer need updates.
await subscription.cancel();
```

Change the ringer mode (Android only; does nothing on iOS):

```dart
await FlutterMute.setRingerMode(RingerMode.Silent);
```

On Android 7.0 and above, the user must grant notification policy access first. Without it, `setRingerMode` throws a `PlatformException`.

```dart
if (!await FlutterMute.isNotificationPolicyAccessGranted) {
  // Opens the system settings screen where the user grants access.
  await FlutterMute.openNotificationPolicySettings();
}
```

## Platform notes

- **iOS** has no public API for the ringer mode. The plugin plays a short silent sound and measures how long playback takes: if it finishes almost instantly, the mute switch is on. It therefore returns only `Normal` or `Vibrate`.
- **`onRingerModeChanged` on iOS** checks the mute switch once per second while the app is in the foreground, because iOS sends no notification when the switch changes. Checks stop while the app is inactive or in the background, and resume when it returns. A change made in the meantime, for example from Control Center, is reported on return. On Android the system pushes each change, so there is no polling.
- **iOS Simulator** always returns `Normal`, and `onRingerModeChanged` never emits.
- **Xcode 27** requires a minimum iOS deployment target of 15.0. If your app still targets 13.0 or 14.0, raise it in your Podfile and Xcode project. This affects every Flutter plugin, not only this one.

## License

GPL-3.0, the same as the original project. See [LICENSE](LICENSE).

Original work © Aleksei Sturov ([flutter_mute](https://github.com/Alezhka/flutter_mute)). iOS mute detection is based on MuteDetect by DianQK. The changes in this fork are listed in [CHANGELOG.md](CHANGELOG.md).
