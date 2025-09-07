import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workmanager/workmanager.dart';

// Background callback for WorkManager
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == "send_sos") {
      print("🚨 SOS triggered in background!");
      // TODO: Call your Django backend API here to send alert
    }
    return Future.value(true);
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize WorkManager
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  // Listen for SOS trigger from native Android (MainActivity.kt)
  const MethodChannel channel = MethodChannel('com.example.silentsos/power_button');
  channel.setMethodCallHandler((call) async {
    if (call.method == "triggerSOS") {
      print("🚨 SOS Triggered (foreground)!");
      HomePage._triggerSOS(); // Call SOS handler
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SilentSOS',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // SOS handler
  static void _triggerSOS() {
    print("🚨 SOS triggered!");
    // Schedule a background task
    Workmanager().registerOneOffTask(
      "uniqueName",
      "send_sos",
      initialDelay: const Duration(seconds: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SilentSOS")),
      body: const Center(
        child: Text("Press the power button 3 times to trigger SOS"),
      ),
    );
  }
}
