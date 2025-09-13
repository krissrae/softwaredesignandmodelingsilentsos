import 'package:flutter/material.dart';
import 'package:screen_state/screen_state.dart';
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
import 'package:silentsos/user.dart';
import 'dark_theme.dart';
import 'utils.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  ThemeMode _themeMode = ThemeMode.light;
  SosDetector? _sosDetector;
  StreamSubscription<ScreenStateEvent>? _screenSubscription;
  final Screen _screen = Screen();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeSosDetection();
    _initializeScreenListener();
  }

  void _initializeSosDetection() {
    _sosDetector = AlertUtils.createSosDetector(
      onSosTriggered: () async {
        print('SOS triggered via detection');
        await AlertUtils.triggerSosAlert();
      },
      requiredPresses: 3,
      timeWindow: Duration(seconds: 2),
    );
  }

  void _initializeScreenListener() {
    try {
      _screenSubscription = _screen.screenStateStream.listen(
        (ScreenStateEvent event) {
          _sosDetector?.recordEvent();
        },
        onError: (error) {
          print('Screen state listener error: $error');
        },
      );
    } catch (e) {
      print('Failed to initialize screen listener: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _screenSubscription?.cancel();
    AlertUtils.cleanupTempAudioFiles();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.resumed) {
      _sosDetector?.recordEvent();
    }
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
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
      themeMode: _themeMode,
      initialRoute: '/dashboard',
      routes: {
        '/': (context) => SplashWelcomePage(toggleTheme: _toggleTheme),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/dashboard': (context) {
          final user = ModalRoute.of(context)?.settings.arguments as User?;
          return HomeDashboardPage(
            onPressSOS: () async {
              // Trigger manual SOS
              bool success = await AlertUtils.triggerSosAlert();
              if (success) {
                Navigator.pushNamed(context, '/countdown');
              } else {
                // Show error dialog or handle failure
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to trigger SOS alert')),
                );
              }
            },
            user: user,
            toggleTheme: _toggleTheme,
          );
        },
        '/countdown': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return PreAlertCountdownPage(
            userEmail: args?['userEmail'] ?? 'radiance@ictuniversity.edu.cm',
          );
        },
        '/receiver': (context) => ReceiverAlertPage(),
        '/profile': (context) => ProfilePage(),
        '/stats': (context) => StatsPage(),
      },
    );
  }
}
