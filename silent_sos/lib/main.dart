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
import 'package:silentsos/user.dart';
import 'dark_theme.dart';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

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
  WebSocketChannel? _alertChannel;

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
    // Initialize WebSocket for real-time alerts
    _initAlertWebSocket();
  }

  void _initAlertWebSocket() {
    // Replace with your backend host/IP as needed
    final wsUrl = 'ws://localhost:8000/ws/alerts/';
    _alertChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
    _alertChannel!.stream.listen((message) {
      try {
        final alert = json.decode(message);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Emergency Alert!'),
            content: Text('User: \\${alert['user']}\nTime: \\${alert['timestamp']}\nLocation: \\${alert['location_link'] ?? 'N/A'}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } catch (e) {
        print('Error parsing alert: $e');
      }
    }, onError: (error) {
      print('WebSocket error: $error');
    }, onDone: () {
      print('WebSocket closed');
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _screenSub?.cancel();
    _alertChannel?.sink.close();
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
    print('Events in window: \\${_events.length}');
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return null;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return null;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied.');
      return null;
    }
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _triggerSos() async {
    print('SOS triggered at \\${DateTime.now()}');
    // Get current location
    Position? position = await _getCurrentLocation();
    String? mapsLink;
    double? lat;
    double? lon;
    if (position != null) {
      lat = position.latitude;
      lon = position.longitude;
      mapsLink = 'https://maps.google.com/?q=$lat,$lon';
      print('Location: $lat, $lon');
      print('Google Maps link: $mapsLink');
    } else {
      print('Location unavailable');
    }
    // Send alert with location and maps link
    try {
      final response = await http.post(
        Uri.parse('https://your-backend.example.com/api/sos/'),
        headers: {'Content-Type': 'application/json'},
        body: '{"user":"radiance","lat":$lat,"lon":$lon,"maps_link":"$mapsLink","timestamp":"${DateTime.now().toUtc().toIso8601String()}"}',
      );
      if (response.statusCode == 200) {
        print('SOS sent');
      } else {
        print('SOS failed: \\${response.statusCode} \\${response.body}');
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
      themeMode: _themeMode,
      initialRoute: '/dashboard',
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
