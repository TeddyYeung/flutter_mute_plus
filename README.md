# flutter_mute_plus

A Flutter plugin to check or toggle the device ringer mode.

A maintained fork of [flutter_mute](https://github.com/Alezhka/flutter_mute) by Aleksei Sturov, updated for current Android, Xcode and Flutter toolchains.

## Why this fork

`flutter_mute` was last published to pub.dev as 0.0.4 in December 2021, and its repository has had no commits since then. Meanwhile the toolchain moved on, and the plugin now breaks or warns in ordinary projects:

| Problem | Upstream report | Upstream status |
|---|---|---|
| Android Gradle Plugin 8 requires `namespace`; the build fails | [Issue #3](https://github.com/Alezhka/flutter_mute/issues/3), [PR #7](https://github.com/Alezhka/flutter_mute/pull/7) | Issue open since Nov 2024; PR closed by its author after going unreviewed |
| Xcode 16: `Cannot find 'TARGET_OS_SIMULATOR' in scope` | [Issue #4](https://github.com/Alezhka/flutter_mute/issues/4), [PR #6](https://github.com/Alezhka/flutter_mute/pull/6) | Open since Apr 2025 |
| Flutter warns that the plugin lacks Swift Package Manager support, and says this will become an error | [Issue #8](https://github.com/Alezhka/flutter_mute/issues/8), [PR #9](https://github.com/Alezhka/flutter_mute/pull/9) | Open since May 2026 |

Fixes for all of these were submitted as pull requests, but the maintainer has not replied to any issue or pull request since 2021. Apps can work around it by pointing at a git fork, but that pins every app to an unversioned commit. `flutter_mute_plus` collects those fixes into a versioned package on pub.dev.

If upstream becomes active again, these changes can be contributed back.

## Features

1. Detect the device's current ringer mode.
2. Switch between Normal, Silent and Vibrate (Android only).
3. Check and request notification policy access, which Android 7.0 (API 24) and above require before the ringer mode can change.

| Mode | Description |
|---|---|
| `RingerMode.Normal` | Normal mode |
| `RingerMode.Silent` | Silent mode (Android only) |
| `RingerMode.Vibrate` | Vibrate mode. On iOS, returned when the mute switch is on |

## Installation

```yaml
dependencies:
  flutter_mute_plus: ^1.0.0
```

## Usage

Get the current ringer mode:

```dart
import 'package:flutter_mute_plus/flutter_mute_plus.dart';

final RingerMode mode = await FlutterMute.getRingerMode();
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

## Migrating from flutter_mute

The Dart API is unchanged. Replace the dependency and the import:

```diff
 dependencies:
-  flutter_mute: ^0.0.4
+  flutter_mute_plus: ^1.0.0
```

```diff
-import 'package:flutter_mute/flutter_mute.dart';
+import 'package:flutter_mute_plus/flutter_mute_plus.dart';
```

Requirements changed: Dart 3, iOS 13.0+, Android minSdk 21.

## Platform notes

- **iOS** has no public API for the ringer mode. The plugin plays a short silent sound and measures how long playback takes: if it finishes almost instantly, the mute switch is on. It therefore returns only `Normal` or `Vibrate`.
- **iOS Simulator** always returns `Normal`.

## License

GPL-3.0, the same as the original project. See [LICENSE](LICENSE).

Original work © Aleksei Sturov ([flutter_mute](https://github.com/Alezhka/flutter_mute)). iOS mute detection is based on MuteDetect by DianQK. The changes in this fork are listed in [CHANGELOG.md](CHANGELOG.md).
