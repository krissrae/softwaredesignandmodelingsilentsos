import 'package:geolocator/geolocator.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'models/alert.dart';
import 'models/risk_area.dart';
import 'services/alerts_service.dart';

class AlertUtils {
  static const String _testEmail = 'radiance@ictuniversity.edu.cm';
  static FlutterSoundRecorder? _recorder;

  // Location utilities
  static Future<bool> requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied.');
      return false;
    }

    return true;
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  static String generateMapsLink(double lat, double lon) {
    return 'https://maps.google.com/?q=$lat,$lon';
  }

  // Audio recording utilities
  static Future<bool> requestAudioPermission() async {
    var status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  static Future<String?> recordAudio({int durationSeconds = 10}) async {
    try {
      bool hasPermission = await requestAudioPermission();
      if (!hasPermission) {
        print('Microphone permission denied');
        return null;
      }

      _recorder = FlutterSoundRecorder();
      await _recorder!.openRecorder();

      Directory tempDir = await getTemporaryDirectory();
      String filePath = '${tempDir.path}/sos_audio_${DateTime.now().millisecondsSinceEpoch}.aac';

      print('Starting audio recording for $durationSeconds seconds...');
      await _recorder!.startRecorder(
        toFile: filePath,
        codec: Codec.aacADTS,
      );

      await Future.delayed(Duration(seconds: durationSeconds));

      await _recorder!.stopRecorder();
      await _recorder!.closeRecorder();

      print('Audio recorded: $filePath');
      return filePath;
    } catch (e) {
      print('Error recording audio: $e');
      return null;
    }
  }

  // Risk area utilities using RiskArea model
  static Map<String, dynamic> createRiskAreaData(double lat, double lon) {
    return {
      'name': 'Emergency Location',
      'description': 'SOS alert triggered at this location',
      'latitude': lat,
      'longitude': lon,
      'radius': 100.0,
    };
  }

  // Alert creation utilities using Alert model
  static Map<String, dynamic> createAlertPayload({
    String? userEmail,
    Position? position,
    String? audioFilePath, // Keep this for reference but don't include in payload
  }) {
    final email = userEmail ?? _testEmail;
    final timestamp = DateTime.now().toUtc().toIso8601String();

    Map<String, dynamic> payload = {
      'alert_type': AlertType.sos.value,
      'email': email,
      'timestamp': timestamp,
      'credibility_score': 1.0,
    };

    if (position != null) {
      payload['location_link'] = generateMapsLink(
        position.latitude,
        position.longitude,
      );
      payload['risk_area'] = createRiskAreaData(
        position.latitude,
        position.longitude,
      );
    }

    // Don't include audio file path in the initial payload
    // Audio will be uploaded separately after alert creation

    return payload;
  }


  // Main SOS trigger function using AlertsService
  static Future<bool> triggerSosAlert({String? userEmail}) async {
    try {
      print('=== TRIGGERING SOS ALERT ===');

      // Get current location
      Position? position = await getCurrentLocation();
      if (position == null) {
        print('Warning: Location unavailable for SOS alert');
      } else {
        print('Location obtained: ${position.latitude}, ${position.longitude}');
      }

      // Record audio
      String? audioPath = await recordAudio(durationSeconds: 10);
      if (audioPath == null) {
        print('Warning: Audio recording failed for SOS alert');
      } else {
        print('Audio recorded successfully');
      }

      // Create alert payload (without audio file path)
      Map<String, dynamic> alertPayload = createAlertPayload(
        userEmail: userEmail,
        position: position,
        // Remove audioFilePath parameter
      );

      print('Alert payload created: $alertPayload');

      // Submit alert using AlertsService
      Map<String, dynamic> createdAlert = await AlertsService.createAlert(alertPayload);
      print('Alert created successfully with ID: ${createdAlert['id']}');

      // If audio was recorded, upload it as a separate request
      if (audioPath != null && createdAlert['id'] != null) {
        try {
          String audioUrl = await AlertsService.uploadAudioFile(
            createdAlert['id'],
            audioPath,
          );
          print('Audio uploaded successfully: $audioUrl');
        } catch (e) {
          print('Audio upload failed (but alert was created): $e');
          // Don't fail the entire operation if audio upload fails
        }
      }

      print('=== SOS ALERT COMPLETED SUCCESSFULLY ===');
      return true;

    } catch (e) {
      print('Error triggering SOS alert: $e');
      print('=== SOS ALERT FAILED ===');
      return false;
    }
  }


  // Get all alerts using AlertsService
  static Future<List<Alert>> getAllAlerts() async {
    try {
      List<Map<String, dynamic>> alertsData = await AlertsService.getAllAlerts();
      return alertsData.map((data) => Alert.fromJson(data)).toList();
    } catch (e) {
      print('Error fetching alerts: $e');
      return [];
    }
  }

  // Get specific alert by ID using AlertsService
  static Future<Alert?> getAlert(int id) async {
    try {
      Map<String, dynamic> alertData = await AlertsService.getAlert(id);
      return Alert.fromJson(alertData);
    } catch (e) {
      print('Error fetching alert $id: $e');
      return null;
    }
  }

  // Check server connectivity
  static Future<bool> isServerAvailable() async {
    try {
      return await AlertsService.checkServerHealth();
    } catch (e) {
      print('Server health check failed: $e');
      return false;
    }
  }

  // Cleanup utility
  static Future<void> cleanupTempAudioFiles() async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      List<FileSystemEntity> files = tempDir.listSync();

      for (FileSystemEntity file in files) {
        if (file.path.contains('sos_audio_') && file.path.endsWith('.aac')) {
          await file.delete();
          print('Deleted temp audio file: ${file.path}');
        }
      }
      print('Temporary audio files cleaned up');
    } catch (e) {
      print('Error cleaning up temp files: $e');
    }
  }

  // Debug utilities
  static Future<void> debugServerConnection() async {
    print('=== DEBUGGING SERVER CONNECTION ===');
    bool isHealthy = await isServerAvailable();
    print('Server health: ${isHealthy ? 'OK' : 'FAILED'}');

    try {
      await AlertsService.debugApiResponse();
    } catch (e) {
      print('Debug API response failed: $e');
    }
    print('=== END DEBUG ===');
  }

  // Validation utilities
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidLocation(Position position) {
    return position.latitude.abs() <= 90 && position.longitude.abs() <= 180;
  }

  static bool isValidAudioFile(String filePath) {
    File file = File(filePath);
    return file.existsSync() && file.lengthSync() > 0;
  }

  // SOS Manager for screen detection (simplified from original)
  static SosDetector createSosDetector({
    required Function() onSosTriggered,
    int requiredPresses = 3,
    Duration timeWindow = const Duration(seconds: 2),
  }) {
    return SosDetector(
      onSosTriggered: onSosTriggered,
      requiredPresses: requiredPresses,
      timeWindow: timeWindow,
    );
  }
}

// Simplified SOS detection class
class SosDetector {
  final Function() onSosTriggered;
  final int requiredPresses;
  final Duration timeWindow;
  final List<DateTime> _events = [];
  bool _sosFired = false;

  SosDetector({
    required this.onSosTriggered,
    required this.requiredPresses,
    required this.timeWindow,
  });

  void recordEvent() {
    final now = DateTime.now();
    _events.add(now);
    _events.removeWhere((t) => now.difference(t) > timeWindow);

    if (!_sosFired && _events.length >= requiredPresses) {
      _sosFired = true;
      _events.clear();
      onSosTriggered();

      // Reset after cooldown
      Future.delayed(Duration(seconds: 5), () => _sosFired = false);
    }

    print('Events in window: ${_events.length}');
  }

  void reset() {
    _events.clear();
    _sosFired = false;
  }
}