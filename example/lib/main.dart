import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mute_plus/flutter_mute_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _status = 'Unknown';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    String status;
    try {
      final mode = await FlutterMute.getRingerMode();
      final isGranted = await FlutterMute.isNotificationPolicyAccessGranted;
      status = '${mode.name} (policy access: $isGranted)';
    } on PlatformException catch (e) {
      status = 'Failed: ${e.message}';
    }

    if (!mounted) return;
    setState(() => _status = status);
  }

  Future<void> _setMode(RingerMode mode) async {
    if (!await FlutterMute.isNotificationPolicyAccessGranted) {
      await FlutterMute.openNotificationPolicySettings();
      return;
    }
    try {
      await FlutterMute.setRingerMode(mode);
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Failed: ${e.message}');
      return;
    }
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_mute_plus example')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ringer mode: $_status'),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _refresh, child: const Text('Refresh')),
              for (final mode in RingerMode.values)
                TextButton(
                  onPressed: () => _setMode(mode),
                  child: Text('Set ${mode.name} (Android only)'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
