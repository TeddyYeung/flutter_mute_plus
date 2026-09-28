import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_mute_plus/flutter_mute_plus.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('getRingerMode returns a mode from the host platform', (WidgetTester tester) async {
    final mode = await FlutterMute.getRingerMode();
    expect(RingerMode.values, contains(mode));
  });
}
