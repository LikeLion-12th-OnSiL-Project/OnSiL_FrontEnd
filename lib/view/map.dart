import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:lion12/view/walk.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late GoogleMapController _controller;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  TextEditingController _startController = TextEditingController();
  TextEditingController _endController = TextEditingController();
  LatLng? _startLocation;
  LatLng? _endLocation;
  Set<Polyline> _polylines = Set<Polyline>();
  Set<Marker> _markers = Set<Marker>();
  double? _distance;
  double? _estimatedTime;

  final String apiKey = 'AIzaSyDV8lz2OkQK8zsSo3Y8S78SgNfJR9HJTMg'; // 구글 api

  @override
  void initState() {
    super.initState();
  }

  Future<void> _calculateRoute() async {
    final startAddress = _startController.text;
    final endAddress = _endController.text;

    if (startAddress.isEmpty || endAddress.isEmpty) {
      _showError('출발지와 도착지를 모두 입력해야 합니다.');
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
          infoWindow: InfoWindow(title: '출발지'),
        ));
        _markers.add(Marker(
          markerId: MarkerId('end'),
          position: endCoords,
          infoWindow: InfoWindow(title: '도착지'),
        ));
      });
      await _calculateWalkingRoute(startCoords, endCoords);
    } else {
      _showError('입력된 주소로 좌표를 가져오는 데 실패했습니다.');
    }
  }

  Future<void> _calculateWalkingRoute(LatLng start, LatLng end) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&mode=walking&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'OK') {
        _processRoute(data);
      } else {
        _showError('경로를 가져오는 데 실패했습니다.');
      }
    } catch (e) {
      _showError('경로를 가져오는 중 오류가 발생했습니다.');
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
        print('좌표 가져오기 실패: ${data['status']}');
        return null;
      }
    } catch (e) {
      print('예외 발생: $e');
      return null;
    }
  }

  void _processRoute(Map<String, dynamic> data) {
    if (data['routes'].isEmpty) {
      _showError('입력된 주소 간의 경로를 찾지 못했습니다.');
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
          title: Text('오류'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendDataToBackend() async {
    final url = 'http://13.125.226.133/location'; // 백엔드 api

    final title = _titleController.text;
    final content = _contentController.text;

    if (title.isEmpty || content.isEmpty) {
      _showError('제목과 내용을 입력해야 합니다.');
      return;
    }

    final body = jsonEncode({
      'title': title,
      'content': content,
      'start_latitude': _startLocation?.latitude ?? 0,
      'start_longitude': _startLocation?.longitude ?? 0,
      'end_latitude': _endLocation?.latitude ?? 0,
      'end_longitude': _endLocation?.longitude ?? 0,
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      print('토큰을 찾을 수 없습니다.');
      return;
    }

    try {
      final response = await http.post(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
          body: body);

      if (response.statusCode == 200) {
        _showSuccess();
      } else {
        _showError('백엔드로 데이터를 보내는 데 실패했습니다.');
      }
    } catch (e) {
      _showError('백엔드로 데이터를 보내는 중 오류가 발생했습니다.');
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('성공'),
          content: Text('등록되었습니다.'),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => MapScreen()),
                );
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
            onPressed: _sendDataToBackend,
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
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '코스 이름을 입력하세요' ,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey ,fontSize: 20),
              ),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: '코스에 대하여 온실 주민과 이야기를 나눠보세요.' ,
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
            GestureDetector(
              onTap: _calculateRoute,
              child: Image.asset('assets/img/route3.png',),
            ),
            SizedBox(height: 10),
            if (_distance != null && _estimatedTime != null)
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('거리: ${_distance!.toStringAsFixed(2)} km'),
                    Text('시간: ${_estimatedTime!.toStringAsFixed(2)} 분'),
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
