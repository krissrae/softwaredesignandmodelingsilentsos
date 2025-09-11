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


import 'package:flutter/material.dart';
import '../styles.dart';
import '../splash_welcome_page.dart';
import '../login_page.dart';
import '../signup_page.dart';
import 'home_dashboard_page.dart';
import '../pre_alert_countdown_page.dart';
import '../receiver_alert_page.dart';
import '../profile_page.dart';
import '../stats_page.dart';
import '../user.dart'; // Make sure this import exists
import 'dark_theme.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SilentSOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        brightness: Brightness.light,
      ),
      darkTheme: DarkTheme.theme,
      themeMode: _themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashWelcomePage(toggleTheme: _toggleTheme),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/dashboard': (context) {
          final user = ModalRoute.of(context)?.settings.arguments as User?;
          return HomeDashboardPage(
            onPressSOS: () {
              Navigator.pushNamed(context, '/countdown');
            },
            user: user,
            toggleTheme: _toggleTheme,
          );
        },
        '/countdown': (context) => PreAlertCountdownPage(),
        '/receiver': (context) => ReceiverAlertPage(),
        '/profile': (context) => ProfilePage(),
        '/stats': (context) => StatsPage(),
      },
    );
  }
}
