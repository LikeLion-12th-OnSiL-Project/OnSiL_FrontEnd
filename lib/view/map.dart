import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late GoogleMapController _controller;
  TextEditingController _courseNameController = TextEditingController();
  TextEditingController _startController = TextEditingController();
  TextEditingController _endController = TextEditingController();
  LatLng? _startLocation;
  LatLng? _endLocation;
  Set<Polyline> _polylines = Set<Polyline>();
  Set<Marker> _markers = Set<Marker>();
  double? _distance;
  double? _estimatedTime;

  final String apiKey = 'YOUR_API_KEY';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _calculateRoute() async {
    final startAddress = _startController.text;
    final endAddress = _endController.text;

    if (startAddress.isEmpty || endAddress.isEmpty) {
      _showError('Both start and end addresses must be provided.');
      return;
    }

    final startCoords = await _getCoordinatesFromAddress(startAddress);
    final endCoords = await _getCoordinatesFromAddress(endAddress);

    if (startCoords != null && endCoords != null) {
      setState(() {
        _startLocation = startCoords;
        _endLocation = endCoords;
        _markers.clear();
        _markers.add(Marker(
          markerId: MarkerId('start'),
          position: startCoords,
          infoWindow: InfoWindow(title: 'Start Location'),
        ));
        _markers.add(Marker(
          markerId: MarkerId('end'),
          position: endCoords,
          infoWindow: InfoWindow(title: 'End Location'),
        ));
      });
      await _getRoute(startCoords, endCoords);
    } else {
      _showError('Failed to get coordinates for provided addresses.');
    }
  }

  Future<LatLng?> _getCoordinatesFromAddress(String address) async {
    final url = 'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'OK') {
        final location = data['results'][0]['geometry']['location'];
        return LatLng(location['lat'], location['lng']);
      } else {
        print('Failed to get coordinates: ${data['status']}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  Future<void> _getRoute(LatLng start, LatLng end) async {
    final origin = '${start.latitude},${start.longitude}';
    final destination = '${end.latitude},${end.longitude}';
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&mode=walking&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);
      print("API Response: $data");

      if (response.statusCode == 200 && data['status'] == 'OK') {
        _processRoute(data);
      } else {
        print('Walking route not found, trying driving mode...');
        await _getRouteDriving(start, end);
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  Future<void> _getRouteDriving(LatLng start, LatLng end) async {
    final origin = '${start.latitude},${start.longitude}';
    final destination = '${end.latitude},${end.longitude}';
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
        _showError('Failed to find a route for the provided addresses.');
      }
    } catch (e) {
      print('Exception: $e');
      _showError('An error occurred while fetching the route.');
    }
  }

  void _processRoute(Map<String, dynamic> data) {
    if (data['routes'].isEmpty) {
      _showError('No routes found between the provided addresses.');
      return;
    }

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
      _polylines.clear();
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

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('                  산책코스 글 쓰기',
        style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Colors.black),),
        actions: [
          TextButton(
            onPressed: () {
              // 완료 버튼을 눌렀을 때의 로직
            },
            child: Container(
              width: 100, // 원하는 너비로 설정
              height: 100, // 원하는 높이로 설정
              child: Image.asset('assets/img/finish2.png'),
            ),
          )

        ],
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _courseNameController,
              decoration: InputDecoration(
                labelText: '코스 이름을 입력하세요' ,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey ,fontSize: 20),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _startController,
              decoration: InputDecoration(
                labelText: '출발지를 입력하세요',
                labelStyle: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.bold),
                prefixIcon: Icon(Icons.place, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _endController,
              decoration: InputDecoration(
                labelText: '도착지를 입력하세요',
                labelStyle: TextStyle(fontSize: 15, color: Colors.grey,fontWeight: FontWeight.bold),
                prefixIcon: Icon(Icons.place, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _calculateRoute,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('경로 계산'),
            ),
            SizedBox(height: 10),
            if (_distance != null && _estimatedTime != null)
              Container(
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
            SizedBox(height: 10),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(37.7749, -122.4194),
                  zoom: 10.0,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                },
                polylines: _polylines,
                markers: _markers,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
