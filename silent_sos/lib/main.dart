import 'package:flutter/material.dart';
import 'package:screen_state/screen_state.dart';
import 'package:http/http.dart'as http;
import 'dart:async';
//import 'package:workmanager/workmanager.dart';
void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  );
}
// Background callback for WorkManager


class MyApp extends StatefulWidget {

  @override
  State<MyApp> createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final Screen _screen = Screen();
  StreamSubscription<ScreenStateEvent>? _screenSub;
  AppLifecycleState? _lastLifecycleState;

  // Buffer for timestamps when screen toggled or lifecycle changed
  final List<DateTime> _events = [];
  final int _requiredPresses = 3;
  final Duration _window = Duration(seconds: 2); // triple-press window

  bool _sosFired = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // subscribe to screen events
    try {
      _screenSub = _screen.screenStateStream.listen(_onScreenEvent);
    } catch (e) {
      // plugin might throw on some platforms — handle gracefully
      print('Screen plugin subscription failed: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _screenSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lastLifecycleState = state;
    // We'll push pause/resume events into the same detector
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.resumed) {
      _recordEvent();
    }
  }

  void _onScreenEvent(ScreenStateEvent event) {
    // Screen ON/OFF events
    //if (event == ScreenStateEvent.SCREEN_OFF || event == ScreenStateEvent.SCREEN_ON) {
    _recordEvent();
  }

  void _recordEvent() {
    final now = DateTime.now();
    _events.add(now);

    // remove old events outside window
    _events.removeWhere((t) => now.difference(t) > _window);

    if (!_sosFired && _events.length >= _requiredPresses) {
      _sosFired = true;
      _events.clear();
      _triggerSos();
      // reset sos after short cooldown
      Future.delayed(Duration(seconds: 5), () => _sosFired = false);
    }
    // optional: debug print
    print('Events in window: ${_events.length}');
  }

  Future<void> _triggerSos() async {
    print('SOS triggered (foreground inferred) at ${DateTime.now()}');
    // Send to your Django backend
    try {
      final response = await http.post(
        Uri.parse('https://your-backend.example.com/api/sos/'),
        headers: {'Content-Type': 'application/json'},
        body: '{"user":"radiance","lat":null,"lon":null,"timestamp":"${DateTime
            .now().toUtc().toIso8601String()}"}',
      );
      if (response.statusCode == 200) {
        print('SOS sent');
      } else {
        print('SOS failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('SOS request error: $e');
    }
    // Provide user feedback in UI (vibrate, show dialog)
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('SOS sent')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('SilentSOS - Foreground Test')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Last lifecycle: $_lastLifecycleState'),
              SizedBox(height: 16),
              Text(
                  'Triple press the power button while app is foreground (in quick succession)'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _recordEvent(), // manual test button
                child: Text('Manual event (test)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

