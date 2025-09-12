import 'package:flutter/material.dart';
import 'package:screen_state/screen_state.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'styles.dart';
import 'splash_welcome_page.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'home_dashboard_page.dart';
import 'pre_alert_countdown_page.dart';
import 'receiver_alert_page.dart';
import 'profile_page.dart';
import 'stats_page.dart';
import 'user.dart';
import 'dark_theme.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  ThemeMode _themeMode = ThemeMode.light;

  // SOS detection variables
  final Screen _screen = Screen();
  StreamSubscription<ScreenStateEvent>? _screenSub;
  AppLifecycleState? _lastLifecycleState;
  final List<DateTime> _events = [];
  final int _requiredPresses = 3;
  final Duration _window = Duration(seconds: 2);
  bool _sosFired = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Subscribe to screen events for SOS detection
    try {
      _screenSub = _screen.screenStateStream.listen(_onScreenEvent);
    } catch (e) {
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
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.resumed) {
      _recordEvent();
    }
  }

  void _onScreenEvent(ScreenStateEvent event) {
    _recordEvent();
  }

  void _recordEvent() {
    final now = DateTime.now();
    _events.add(now);

    _events.removeWhere((t) => now.difference(t) > _window);

    if (!_sosFired && _events.length >= _requiredPresses) {
      _sosFired = true;
      _events.clear();
      _triggerSos();
      Future.delayed(Duration(seconds: 5), () => _sosFired = false);
    }
    print('Events in window: ${_events.length}');
  }

  Future<void> _triggerSos() async {
    print('SOS triggered at ${DateTime.now()}');
    try {
      final response = await http.post(
        Uri.parse('https://your-backend.example.com/api/sos/'),
        headers: {'Content-Type': 'application/json'},
        body: '{"user":"radiance","lat":null,"lon":null,"timestamp":"${DateTime.now().toUtc().toIso8601String()}"}',
      );
      if (response.statusCode == 200) {
        print('SOS sent');
      } else {
        print('SOS failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('SOS request error: $e');
    }
  }

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