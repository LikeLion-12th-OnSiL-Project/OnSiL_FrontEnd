import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapWidget extends StatefulWidget {
  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late GoogleMapController _controller;
  LatLng? _startLocation;
  LatLng? _endLocation;
  Set<Polyline> _polylines = Set<Polyline>();
  Set<Marker> _markers = Set<Marker>();
  double? _distance;
  double? _estimatedTime;

  final String apiKey = 'YOUR_API_KEY_HERE'; // Google Maps API Key 입력

  Future<void> _getRoute() async {
    if (_startLocation == null || _endLocation == null) return;

    final origin = '${_startLocation!.latitude},${_startLocation!.longitude}';
    final destination = '${_endLocation!.latitude},${_endLocation!.longitude}';
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&mode=walking&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);
      print("API Response: $data");

      if (response.statusCode == 200 && data['status'] == 'OK') {
        _processRoute(data);
      } else {
        // 도보 경로를 찾지 못했을 경우 운전 모드로 시도
        print('Walking route not found, trying driving mode...');
        await _getRouteDriving();
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  Future<void> _getRouteDriving() async {
    if (_startLocation == null || _endLocation == null) return;

    final origin = '${_startLocation!.latitude},${_startLocation!.longitude}';
    final destination = '${_endLocation!.latitude},${_endLocation!.longitude}';
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&mode=driving&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);
      print("API Response (Driving): $data");

      if (response.statusCode == 200 && data['status'] == 'OK') {
        _processRoute(data);
      } else {
        print('Failed to load route (Driving): ${response.body}');
        throw Exception('Failed to load route (Driving): ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  void _processRoute(Map<String, dynamic> data) {
    final route = data['routes'][0];
    final leg = route['legs'][0];
    final distanceMeters = leg['distance']['value'];
    final durationSeconds = leg['duration']['value'];

    setState(() {
      _distance = distanceMeters / 1000; // 거리(km)
      _estimatedTime = durationSeconds / 60; // 시간(분)
    });

    final polylinePoints = route['overview_polyline']['points'];
    final decodedPoints = _decodePolyline(polylinePoints);

    setState(() {
      _polylines.add(Polyline(
        width: 5,
        polylineId: PolylineId('route'),
        color: Color.fromARGB(255, 40, 122, 198),
        points: decodedPoints,
      ));
    });
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()));
    }

    return points;
  }

  void _selectLocation(LatLng location, bool isStart) {
    setState(() {
      if (isStart) {
        _startLocation = location;
        _markers.add(
          Marker(
            markerId: MarkerId('start'),
            position: location,
            infoWindow: InfoWindow(title: 'Start Location'),
          ),
        );
      } else {
        _endLocation = location;
        _markers.add(
          Marker(
            markerId: MarkerId('end'),
            position: location,
            infoWindow: InfoWindow(title: 'End Location'),
          ),
        );
      }
      if (_startLocation != null && _endLocation != null) {
        _getRoute();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Map Navigation'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(37.532600, 127.024612), // 초기 위치
              zoom: 14.4746,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            onTap: (LatLng location) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Select Location'),
                  content: Text('Is this the start or end location?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _selectLocation(location, true);
                        Navigator.pop(context);
                      },
                      child: Text('Start'),
                    ),
                    TextButton(
                      onPressed: () {
                        _selectLocation(location, false);
                        Navigator.pop(context);
                      },
                      child: Text('End'),
                    ),
                  ],
                ),
              );
            },
            polylines: _polylines,
            markers: _markers,
          ),
          if (_distance != null && _estimatedTime != null)
            Positioned(
              top: 20,
              left: 10,
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Distance: ${_distance!.toStringAsFixed(2)} km'),
                    Text('Estimated Time: ${_estimatedTime!.toStringAsFixed(2)} min'),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // 필요 시 기능 추가
        child: Icon(Icons.my_location),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
