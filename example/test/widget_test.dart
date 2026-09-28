import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mute_plus/flutter_mute_plus.dart';

import 'package:flutter_mute_plus_example/main.dart';

void main() {
  testWidgets('shows the ringer mode reported by the plugin', (WidgetTester tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      FlutterMute.channel,
      (MethodCall call) async => call.method == 'getRingerMode' ? RingerMode.Vibrate.index : true,
    );

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Ringer mode: Vibrate'), findsOneWidget);
  });
}
