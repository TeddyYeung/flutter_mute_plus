import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mute_plus/flutter_mute_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final calls = <MethodCall>[];
  Object? reply;

  setUp(() {
    calls.clear();
    reply = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      FlutterMute.channel,
      (MethodCall call) async {
        calls.add(call);
        return reply;
      },
    );
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(FlutterMute.channel, null);
  });

  test('channel name does not collide with flutter_mute', () {
    expect(FlutterMute.channel.name, 'flutter_mute_plus');
  });

  test('getRingerMode maps the native index to RingerMode', () async {
    for (final mode in RingerMode.values) {
      reply = mode.index;
      expect(await FlutterMute.getRingerMode(), mode);
    }
  });

  test('onRingerModeChanged maps native events to RingerMode', () async {
    expect(FlutterMute.ringerModeChangesChannel.name, 'flutter_mute_plus/ringer_mode_changes');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockStreamHandler(
      FlutterMute.ringerModeChangesChannel,
      MockStreamHandler.inline(
        onListen: (_, events) {
          events.success(RingerMode.Vibrate.index);
          events.success(RingerMode.Normal.index);
          events.endOfStream();
        },
      ),
    );
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockStreamHandler(
        FlutterMute.ringerModeChangesChannel,
        null,
      ),
    );

    expect(await FlutterMute.onRingerModeChanged.toList(), [RingerMode.Vibrate, RingerMode.Normal]);
  });

  group('on Android', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);

    test('setRingerMode sends the mode index', () async {
      reply = true;
      await FlutterMute.setRingerMode(RingerMode.Silent);

      expect(calls.single.method, 'setRingerMode');
      expect(calls.single.arguments, {'mode': RingerMode.Silent.index});
    });

    test('isNotificationPolicyAccessGranted returns the native value', () async {
      reply = false;
      expect(await FlutterMute.isNotificationPolicyAccessGranted, isFalse);
    });

    test('openNotificationPolicySettings completes', () async {
      await FlutterMute.openNotificationPolicySettings();
      expect(calls.single.method, 'openNotificationPolicySettings');
    });
  });

  group('on iOS', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.iOS);

    test('Android-only APIs do not call the platform', () async {
      await FlutterMute.setRingerMode(RingerMode.Silent);
      await FlutterMute.openNotificationPolicySettings();

      expect(await FlutterMute.isNotificationPolicyAccessGranted, isTrue);
      expect(calls, isEmpty);
    });
  });
}
