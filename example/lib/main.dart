import 'dart:async';

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
  final List<String> _changes = [];
  late final StreamSubscription<RingerMode> _changesSubscription;

  @override
  void initState() {
    super.initState();
    _refresh();
    _changesSubscription = FlutterMute.onRingerModeChanged.listen(_onRingerModeChanged);
  }

  @override
  void dispose() {
    _changesSubscription.cancel();
    super.dispose();
  }

  void _onRingerModeChanged(RingerMode mode) {
    final time = DateTime.now().toIso8601String().substring(11, 19);
    setState(() => _changes.insert(0, '$time  ${mode.name}'));
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
              const SizedBox(height: 16),
              const Text('onRingerModeChanged'),
              for (final change in _changes.take(5)) Text(change),
            ],
          ),
        ),
      ),
    );
  }
}
