import 'package:flutter/material.dart';
import 'services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _currentPosition;
  String? _error;

  @override
  void initState() {
    super.initState();
    _getLocation();
    // Listen for real-time updates
    LocationService.getPositionStream().listen((Position position) {
      setState(() {
        _currentPosition = position;
        _error = null;
      });
    }, onError: (e) {
      setState(() {
        _error = e.toString();
      });
    });
  }

  Future<void> _getLocation() async {
    final pos = await LocationService.getCurrentLocation();
    if (pos != null) {
      setState(() {
        _currentPosition = pos;
        _error = null;
      });
    } else {
      setState(() {
        _error = 'Location unavailable or permission denied.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String locationText = 'Fetching location...';
    String? mapsUrl;
    if (_currentPosition != null) {
      locationText = 'Lat: ${_currentPosition!.latitude}, Lng: ${_currentPosition!.longitude}';
      mapsUrl = 'https://maps.google.com/?q=${_currentPosition!.latitude},${_currentPosition!.longitude}';
    } else if (_error != null) {
      locationText = _error!;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("SilentSOS Home"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: (){
                //trigger for alert
              },
              child: const Text("Send SOS"),
            ),
            const SizedBox(height: 20),
            const Text("Your location: "),
            Container(
              height: 100,
              width: double.infinity,
              color: Colors.grey[300],
              child: Center(
                child: mapsUrl != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(locationText),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {

                            // Open Google Maps link
                            // You may want to use url_launcher package for this
                          },
                          child: const Text(
                            "Open in Google Maps",
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Text(locationText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}