import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

class AlertsService {
  static const String baseUrl = 'http://192.168.88.115:8000/alerts/';
  static const Duration _timeout = Duration(seconds: 10);

  // GET all alerts with console logging - updated to handle paginated response
  static Future<List<Map<String, dynamic>>> getAllAlerts() async {
    print('=== FETCHING ALL ALERTS ===');
    try {
      final response = await http
          .get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(_timeout);

      print('Status Code: ${response.statusCode}');
      print('Raw Response: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        print('Response Type: ${decoded.runtimeType}');

        if (decoded is Map<String, dynamic> && decoded.containsKey('results')) {
          // Handle paginated response
          final results = decoded['results'] as List;
          final count = decoded['count'] ?? 0;
          final next = decoded['next'];
          final previous = decoded['previous'];

          print('Pagination info:');
          print('  Total count: $count');
          print('  Next page: $next');
          print('  Previous page: $previous');
          print('  Results in this page: ${results.length}');

          // Log each alert
          for (int i = 0; i < results.length; i++) {
            final alert = results[i];
            print('--- Alert ${i + 1} ---');
            print('ID: ${alert['id']}');
            print('Alert Type: ${alert['alert_type']}');
            print('Timestamp: ${alert['timestamp']}');
            print('User: ${alert['user']}');
            print('Risk Area: ${alert['risk_area']}');
            print('Location Link: ${alert['location_link']}');
            print('Audio: ${alert['audio']}');
            print('Full Alert Data: $alert');
            print('');
          }

          print('=== END ALERTS FETCH ===\n');
          return results.cast<Map<String, dynamic>>();

        } else if (decoded is List) {
          // Handle direct array response (fallback)
          print('Direct array response with ${decoded.length} alerts');
          print('=== END ALERTS FETCH ===\n');
          return decoded.cast<Map<String, dynamic>>();

        } else {
          print('Unexpected response format: ${decoded.runtimeType}');
          print('Response keys: ${decoded is Map ? (decoded as Map).keys.toList() : 'N/A'}');
          print('=== END ALERTS FETCH ===\n');
          throw Exception('Unexpected response format');
        }
      } else {
        print('Error: Failed to load alerts with status ${response.statusCode}');
        print('=== END ALERTS FETCH ===\n');
        throw Exception('Failed to load alerts: ${response.statusCode}');
      }
    } on SocketException {
      print('Error: No internet connection or server unreachable');
      print('=== END ALERTS FETCH ===\n');
      throw Exception('No internet connection or server unreachable');
    } on TimeoutException {
      print('Error: Request timeout - server may be down');
      print('=== END ALERTS FETCH ===\n');
      throw Exception('Request timeout - server may be down');
    } on FormatException catch (e) {
      print('JSON parsing error: $e');
      print('=== END ALERTS FETCH ===\n');
      throw Exception('Invalid JSON response from server');
    } catch (e) {
      print('Detailed error: $e');
      print('=== END ALERTS FETCH ===\n');
      throw Exception('Error fetching alerts: $e');
    }
  }

  // GET alert by ID with console logging
  static Future<Map<String, dynamic>> getAlert(int id) async {
    print('=== FETCHING ALERT $id ===');
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(_timeout);

      print('Status Code: ${response.statusCode}');
      print('Raw Response: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          print('Alert Retrieved:');
          print('ID: ${decoded['id']}');
          print('Alert Type: ${decoded['alert_type']}');
          print('Timestamp: ${decoded['timestamp']}');
          print('User: ${decoded['user']}');
          print('Risk Area: ${decoded['risk_area']}');
          print('Full Alert: $decoded');
          print('=== END ALERT FETCH ===\n');
          return decoded;
        } else {
          print('Unexpected response type: ${decoded.runtimeType}');
          print('=== END ALERT FETCH ===\n');
          throw Exception('Expected Map<String, dynamic> but got ${decoded.runtimeType}');
        }
      } else if (response.statusCode == 404) {
        print('Alert not found');
        print('=== END ALERT FETCH ===\n');
        throw Exception('Alert not found');
      } else {
        print('Error: Failed to load alert with status ${response.statusCode}');
        print('=== END ALERT FETCH ===\n');
        throw Exception('Failed to load alert: ${response.statusCode}');
      }
    } on SocketException {
      print('Error: No internet connection or server unreachable');
      print('=== END ALERT FETCH ===\n');
      throw Exception('No internet connection or server unreachable');
    } on TimeoutException {
      print('Error: Request timeout - server may be down');
      print('=== END ALERT FETCH ===\n');
      throw Exception('Request timeout - server may be down');
    } on FormatException {
      print('Error: Invalid JSON response from server');
      print('=== END ALERT FETCH ===\n');
      throw Exception('Invalid JSON response from server');
    } catch (e) {
      print('Error fetching alert: $e');
      print('=== END ALERT FETCH ===\n');
      throw Exception('Error fetching alert: $e');
    }
  }

  // GET paginated alerts with page parameter
  static Future<Map<String, dynamic>> getPaginatedAlerts({int page = 1, int pageSize = 10}) async {
    print('=== FETCHING PAGINATED ALERTS (Page $page) ===');
    try {
      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        'page': page.toString(),
        'page_size': pageSize.toString(),
      });

      final response = await http
          .get(
        uri,
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(_timeout);

      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);

        if (decoded is Map<String, dynamic>) {
          final results = (decoded['results'] as List?)?.cast<Map<String, dynamic>>() ?? [];

          return {
            'results': results,
            'count': decoded['count'] ?? 0,
            'next': decoded['next'],
            'previous': decoded['previous'],
            'current_page': page,
            'page_size': pageSize,
          };
        }
      }

      throw Exception('Failed to load paginated alerts: ${response.statusCode}');
    } catch (e) {
      print('Error fetching paginated alerts: $e');
      print('=== END PAGINATED ALERTS FETCH ===\n');
      throw Exception('Error fetching paginated alerts: $e');
    }
  }

  // Enhanced debug method that handles paginated response
  static Future<void> debugApiResponse() async {
    print('\n=== COMPREHENSIVE ALERTS DEBUG ===');
    try {
      final response = await http
          .get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(_timeout);

      print('API URL: $baseUrl');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Raw Response Body: ${response.body}');
      print('Response Body Length: ${response.body.length}');

      if (response.statusCode != 200) {
        print('Non-200 status code received!');
        print('=== END DEBUG ===\n');
        return;
      }

      final decoded = json.decode(response.body);
      print('Decoded Response Type: ${decoded.runtimeType}');

      if (decoded is Map<String, dynamic>) {
        print('Response is paginated object');
        print('Keys: ${decoded.keys.toList()}');

        if (decoded.containsKey('results')) {
          final results = decoded['results'] as List;
          print('Number of alerts in results: ${results.length}');
          print('Total count: ${decoded['count']}');
          print('Next page: ${decoded['next']}');
          print('Previous page: ${decoded['previous']}');

          if (results.isNotEmpty) {
            print('\n--- DETAILED ALERT ANALYSIS ---');
            for (int i = 0; i < results.length; i++) {
              final alert = results[i];
              print('\nALERT ${i + 1}:');
              print('  Raw data: $alert');
              print('  Data type: ${alert.runtimeType}');

              if (alert is Map<String, dynamic>) {
                print('  Keys: ${alert.keys.toList()}');
                alert.forEach((key, value) {
                  print('    $key: $value (${value.runtimeType})');
                  if (value is Map<String, dynamic>) {
                    print('      Nested keys: ${value.keys.toList()}');
                    value.forEach((nestedKey, nestedValue) {
                      print('        $nestedKey: $nestedValue (${nestedValue.runtimeType})');
                    });
                  }
                });
              }
            }
          } else {
            print('No alerts found in results');
          }
        }
      } else if (decoded is List) {
        print('Response is direct array (legacy format)');
        print('Number of alerts: ${decoded.length}');
        // Handle legacy format...
      } else {
        print('Unexpected response format: ${decoded.runtimeType}');
        print('Response content: $decoded');
      }

      print('=== END DEBUG ===\n');
    } catch (e) {
      print('Debug error: $e');
      print('=== END DEBUG ===\n');
    }
  }

  // POST create new alert - no validation
  static Future<Map<String, dynamic>> createAlert(
    Map<String, dynamic> alertData,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(alertData),
          )
          .timeout(_timeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else {
          throw Exception(
            'Expected Map<String, dynamic> but got ${decoded.runtimeType}',
          );
        }
      } else if (response.statusCode == 400) {
        final errorBody = json.decode(response.body);
        throw Exception('Invalid alert data: $errorBody');
      } else {
        throw Exception('Failed to create alert: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection or server unreachable');
    } on TimeoutException {
      throw Exception('Request timeout - server may be down');
    } on FormatException {
      throw Exception('Invalid JSON response from server');
    } catch (e) {
      throw Exception('Error creating alert: $e');
    }
  }

  // PUT update existing alert - no validation
  static Future<Map<String, dynamic>> updateAlert(
    int id,
    Map<String, dynamic> alertData,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/$id'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(alertData),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else {
          throw Exception(
            'Expected Map<String, dynamic> but got ${decoded.runtimeType}',
          );
        }
      } else if (response.statusCode == 404) {
        throw Exception('Alert not found');
      } else if (response.statusCode == 400) {
        final errorBody = json.decode(response.body);
        throw Exception('Invalid alert data: $errorBody');
      } else {
        throw Exception('Failed to update alert: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection or server unreachable');
    } on TimeoutException {
      throw Exception('Request timeout - server may be down');
    } on FormatException {
      throw Exception('Invalid JSON response from server');
    } catch (e) {
      throw Exception('Error updating alert: $e');
    }
  }

  // PATCH partially update existing alert - no validation
  static Future<Map<String, dynamic>> patchAlert(
    int id,
    Map<String, dynamic> alertData,
  ) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$baseUrl/$id'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(alertData),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else {
          throw Exception(
            'Expected Map<String, dynamic> but got ${decoded.runtimeType}',
          );
        }
      } else if (response.statusCode == 404) {
        throw Exception('Alert not found');
      } else if (response.statusCode == 400) {
        final errorBody = json.decode(response.body);
        throw Exception('Invalid alert data: $errorBody');
      } else {
        throw Exception('Failed to patch alert: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection or server unreachable');
    } on TimeoutException {
      throw Exception('Request timeout - server may be down');
    } on FormatException {
      throw Exception('Invalid JSON response from server');
    } catch (e) {
      throw Exception('Error patching alert: $e');
    }
  }

  // DELETE alert
  static Future<void> deleteAlert(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/$id'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 204 || response.statusCode == 200) {
        return;
      } else if (response.statusCode == 404) {
        throw Exception('Alert not found');
      } else {
        throw Exception('Failed to delete alert: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection or server unreachable');
    } on TimeoutException {
      throw Exception('Request timeout - server may be down');
    } catch (e) {
      throw Exception('Error deleting alert: $e');
    }
  }

  // GET alerts by user ID - no validation
  static Future<List<Map<String, dynamic>>> getAlertsByUser(int userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl?user_id=$userId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded.cast<Map<String, dynamic>>();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load user alerts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user alerts: $e');
    }
  }

  // GET alerts by risk area ID - no validation
  static Future<List<Map<String, dynamic>>> getAlertsByRiskArea(
    int riskAreaId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl?risk_area_id=$riskAreaId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded.cast<Map<String, dynamic>>();
        } else {
          return [];
        }
      } else {
        throw Exception(
          'Failed to load risk area alerts: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching risk area alerts: $e');
    }
  }

  // GET alerts by alert type - no validation
  static Future<List<Map<String, dynamic>>> getAlertsByType(
    String alertType,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl?alert_type=$alertType'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded.cast<Map<String, dynamic>>();
        } else {
          return [];
        }
      } else {
        throw Exception(
          'Failed to load alerts by type: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching alerts by type: $e');
    }
  }

  // Helper method to check server connectivity
  static Future<bool> checkServerHealth() async {
    try {
      final response = await http
          .get(
            Uri.parse(baseUrl.replaceAll('/alerts', '/health')),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Upload audio file for an alert
  static Future<String> uploadAudioFile(int alertId, String filePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/$alertId/audio'),
      );

      request.files.add(await http.MultipartFile.fromPath('audio', filePath));

      final response = await request.send().timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        final decoded = json.decode(responseBody);
        return decoded['audio_url'] ?? decoded['audio'] ?? '';
      } else {
        throw Exception('Failed to upload audio: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Upload timeout');
    } catch (e) {
      throw Exception('Error uploading audio: $e');
    }
  }
}
