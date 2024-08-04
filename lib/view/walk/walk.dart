import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'map.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<dynamic> _courses = [];

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    final response = await http.get(Uri.parse('http://13.125.226.133/location'));
    if (response.statusCode == 200) {
      setState(() {
        _courses = jsonDecode(utf8.decode(response.bodyBytes));
      });
    } else {
      throw Exception('Failed to load courses');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '안서동산책러님을 위한 추천 코스',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _courses.length,
                itemBuilder: (context, index) {
                  return RecommendedCourseCard(
                    title: _courses[index]['title'],
                    startDistance: '출발지점 ${_courses[index]['start_latitude']}m',
                    courseLength: '코스길이 ${_courses[index]['end_latitude']}Km',
                    imageUrl: 'assets/course${index + 1}.png',
                    startlat: _courses[index]['start_latitude'],
                    startlong: _courses[index]['start_longitude'],
                    endlat: _courses[index]['end_latitude'],
                    endlong: _courses[index]['end_longitude'],
                    id: _courses[index],
                  );
                },
              ),
            ),
            ..._courses.map((course) => WalkPost(post: course)).toList(),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => MapWidget()));
        },
        child: Image.asset('assets/img/add.png'),
      ),
    );
  }
}

class RecommendedCourseCard extends StatefulWidget {
  final String title;
  final String startDistance;
  final String courseLength;
  final String imageUrl;
  final dynamic startlat;
  final dynamic startlong;
  final dynamic endlat;
  final dynamic endlong;
  final dynamic id;


  const RecommendedCourseCard({super.key,
    required this.title,
    required this.startDistance,
    required this.courseLength,
    required this.imageUrl, this.startlat, this.startlong, this.endlat, this.endlong, this.id,
  });

  @override
  State<RecommendedCourseCard> createState() => _RecommendedCourseCardState();
}


class _RecommendedCourseCardState extends State<RecommendedCourseCard> {

  @override
  void initState() {
    super.initState();
    _calculateRoute();
  }
  final String apiKey = 'AIzaSyDV8lz2OkQK8zsSo3Y8S78SgNfJR9HJTMg'; // Google API key
  Set<Polyline> _polylines = {};
  LatLng? _startLocation;
  LatLng? _endLocation;
  Set<Marker> _markers = Set<Marker>();
  GoogleMapController? _controller; // nullable controller
  double? _distance;
  double? _estimatedTime;


  Future<void> _calculateRoute() async {
    final startCoords = LatLng(widget.startlat.toDouble(), widget.startlong.toDouble());
    final endCoords = LatLng(widget.endlat.toDouble(), widget.endlong.toDouble());

    if (startCoords != null && endCoords != null) {
      setState(() {
        _startLocation = startCoords;
        _endLocation = endCoords;
        _markers.clear();
        _markers.add(Marker(
          markerId: MarkerId('start-${widget.id}'),
          position: startCoords,
          infoWindow: InfoWindow(title: '출발지'),
        ));
        _markers.add(Marker(
          markerId: MarkerId('end-${widget.id}'),
          position: endCoords,
          infoWindow: InfoWindow(title: '도착지'),
        ));
      });
      await _calculateWalkingRoute(startCoords, endCoords);
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
        print("Error fetching route: ${data['status']}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _processRoute(Map<String, dynamic> data) {
    if (data['routes'].isEmpty) {
      return;
    }

    final route = data['routes'][0];
    final leg = route['legs'][0];
    final distanceMeters = leg['distance']['value'];
    final durationSeconds = leg['duration']['value'];

    setState(() {
      _distance = distanceMeters / 1000; // Distance in km
      _estimatedTime = durationSeconds / 60; // Time in minutes
    });

    final polylinePoints = route['overview_polyline']['points'];
    final decodedPoints = _decodePolyline(polylinePoints);

    setState(() {
      _polylines.clear();
      _polylines.add(Polyline(
        width: 5,
        polylineId: PolylineId('route-${widget.id}'),
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


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 코스 카드 클릭 시 동작 추가
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              child: Container(
                child: SizedBox(
                  height: 135, // Adjust the height as needed
                  child: GoogleMap(
                    zoomControlsEnabled: false, // Disable zoom controls
                    initialCameraPosition: CameraPosition(
                      target: LatLng(widget.startlat.toDouble(), widget.startlong.toDouble()),
                      zoom: 10.0,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _controller = controller;
                      // _calculateRoute(); // This line is removed to avoid duplicate route calculations
                    },
                    polylines: _polylines,
                    markers: _markers,
                  ),
                ),
              ),
            ),
            Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(widget.startDistance),
                    Text(widget.courseLength),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class WalkPost extends StatefulWidget {
  final Map<String, dynamic> post;


  const WalkPost({required this.post, Key? key}) : super(key: key);

  @override
  _WalkPostState createState() => _WalkPostState();
}

class _WalkPostState extends State<WalkPost> {
  final String apiKey = 'AIzaSyDV8lz2OkQK8zsSo3Y8S78SgNfJR9HJTMg'; // Google API key
  int _likes = 0; // Initial likes count
  bool _isLiked = false; // Like state
  int _comments = 0;
  Set<Polyline> _polylines = {};
  LatLng? _startLocation;
  LatLng? _endLocation;
  Set<Marker> _markers = Set<Marker>();
  GoogleMapController? _controller; // nullable controller
  double? _distance;
  double? _estimatedTime;

  @override
  void initState() {
    super.initState();
    _likes = widget.post['likes'];
    _comments = widget.post['replies'];
    _calculateRoute(); // Calculate route when initializing
  }

  void _toggleLikes() {
    setState(() {
      if (_isLiked) {
        _likes--;
      } else {
        _likes++;
      }
      _isLiked = !_isLiked;
    });
  }

  Future<void> _calculateRoute() async {
    final startCoords = LatLng(widget.post['start_latitude'].toDouble(), widget.post['start_longitude'].toDouble());
    final endCoords = LatLng(widget.post['end_latitude'].toDouble(), widget.post['end_longitude'].toDouble());

    if (startCoords != null && endCoords != null) {
      setState(() {
        _startLocation = startCoords;
        _endLocation = endCoords;
        _markers.clear();
        _markers.add(Marker(
          markerId: MarkerId('start-${widget.post['id']}'),
          position: startCoords,
          infoWindow: InfoWindow(title: '출발지'),
        ));
        _markers.add(Marker(
          markerId: MarkerId('end-${widget.post['id']}'),
          position: endCoords,
          infoWindow: InfoWindow(title: '도착지'),
        ));
      });
      await _calculateWalkingRoute(startCoords, endCoords);
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
        print("Error fetching route: ${data['status']}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _processRoute(Map<String, dynamic> data) {
    if (data['routes'].isEmpty) {
      return;
    }

    final route = data['routes'][0];
    final leg = route['legs'][0];
    final distanceMeters = leg['distance']['value'];
    final durationSeconds = leg['duration']['value'];

    setState(() {
      _distance = distanceMeters / 1000; // Distance in km
      _estimatedTime = durationSeconds / 60; // Time in minutes
    });

    final polylinePoints = route['overview_polyline']['points'];
    final decodedPoints = _decodePolyline(polylinePoints);

    setState(() {
      _polylines.clear();
      _polylines.add(Polyline(
        width: 5,
        polylineId: PolylineId('route-${widget.post['id']}'),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(post: widget.post),
          ),
        );
      },
      child: Container(
        // decoration: BoxDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 20, 8, 10),
              child: Row(
                children: [
                  Image.asset(
                    'assets/img/man.png',
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.post['writer']),
                      Text(widget.post['content']),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 200,
              color: Colors.white,
              child: GoogleMap(
                zoomControlsEnabled: false, // Disable zoom controls
                initialCameraPosition: CameraPosition(

                  target: LatLng(widget.post['start_latitude'].toDouble(), widget.post['start_longitude'].toDouble()),
                  zoom: 10.0,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                  // _calculateRoute(); // This line is removed to avoid duplicate route calculations
                },
                polylines: _polylines,
                markers: _markers,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: _toggleLikes,
                      child: Image.asset(
                        'assets/img/heart.png',
                        width: 24,
                        height: 24,
                        color: _isLiked ? Colors.red : Colors.black,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text('$_likes'),
                    SizedBox(width: 20),
                    IconButton(
                      onPressed: () {},
                      icon: Image.asset(
                        'assets/img/chat.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    Text('$_comments'),
                    SizedBox(width: 20),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class DetailPage extends StatefulWidget {
  final Map<String, dynamic> post;


  const DetailPage({required this.post, Key? key}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Map<String, dynamic>? userData;
  final String username = "민석";
  int helpCount = 0;
  bool isHelped = false;
  List<Map<String, dynamic>> comments = [];
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchComments();
    fetchUserData();
    print(widget.post["id"]);
  }

  void _showCommentInputModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Ensure modal expands to fit keyboard
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: commentController,
                decoration: inputDecoration.copyWith(
                  hintText: '댓글을 입력해주세요.',
                ),
                keyboardType: TextInputType.text,
                autofocus: true,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  submitComment();
                  Navigator.pop(context); // Close the modal
                },
                child: Text('댓글 작성'),
              ),
            ],
          ),
        );
      },
    );
  }


  void _toggleHelp() {
    setState(() {
      if (isHelped) {
        helpCount--;
      } else {
        helpCount++;
      }
      isHelped = !isHelped;
    });
  }

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      print('토큰을 찾을 수 없습니다.');
      return;
    }
    final response = await http.get(
      Uri.parse('https://example.com/user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        userData = jsonDecode(utf8.decode(response.bodyBytes));
      });
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<void> fetchComments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      print('토큰을 찾을 수 없습니다.');
      return;
    }
    final response = await http.get(
      Uri.parse('http://13.125.226.133/location-reply?locationId=8'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        comments = List<Map<String, dynamic>>.from(jsonDecode(utf8.decode(response.bodyBytes)));
      });
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<void> submitComment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      print('토큰을 찾을 수 없습니다.');
      return;
    }
    if (commentController.text.isEmpty) return;

    final response = await http.post(
      Uri.parse('http://13.125.226.133/location-reply/8'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'writer': username, // Replace with actual writer name
        'content': commentController.text,
        'locationId': 8,
      }),
    );
    print(jsonEncode(<String, dynamic>{
      'writer': username, // Replace with actual writer name
      'content': commentController.text,
      'locationId': 8,
    }));

    if (response.statusCode == 200) {
      setState(() {
        comments.add({
          'writer': username, // Replace with actual writer name
          'content': commentController.text,
          'locationId': 8//widget.post['id'],
        });
        commentController.clear();
      });
    } else {
      throw Exception('Failed to submit comment');
    }
  }
  InputDecoration inputDecoration = InputDecoration(
    hintText: '댓글을 입력해주세요.',
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: Image.asset('assets/img/bell.png'),
            onPressed: () {},
          ),
        ],
      ),
      bottomSheet: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: '댓글을 입력해주세요.',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: submitComment,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Your content here
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Image.asset('assets/img/man.png'),
                  title: Text(widget.post['writer']),
                  subtitle: Text(widget.post['content']),
                ),
                Container(
                  height: 200,
                  color: Colors.white,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        widget.post['start_latitude'].toDouble(),
                        widget.post['start_longitude'].toDouble(),
                      ),
                      zoom: 14,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('startMarker'),
                        position: LatLng(
                          widget.post['start_latitude'].toDouble(),
                          widget.post['start_longitude'].toDouble(),
                        ),
                      ),
                      Marker(
                        markerId: MarkerId('endMarker'),
                        position: LatLng(
                          widget.post['end_latitude'].toDouble(),
                          widget.post['end_longitude'].toDouble(),
                        ),
                      ),
                    },
                    polylines: {
                      Polyline(
                        polylineId: PolylineId('route'),
                        points: [
                          LatLng(
                            widget.post['start_latitude'].toDouble(),
                            widget.post['start_longitude'].toDouble(),
                          ),
                          LatLng(
                            widget.post['end_latitude'].toDouble(),
                            widget.post['end_longitude'].toDouble(),
                          ),
                        ],
                        color: Colors.blue,
                        width: 5,
                      ),
                    },
                  ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _toggleHelp,
                      icon: Icon(
                        Icons.thumb_up,
                        color: isHelped ? Colors.blue : Colors.grey,
                      ),
                      label: Text(
                        '도움이 돼요 ${helpCount}',
                        style: TextStyle(
                          color: isHelped ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.reply, color: Colors.grey),
                      label: Text('공유하기', style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
                Divider(),
                Expanded(
                  child: comments.isEmpty
                      ? Center(child: Text('댓글이 없습니다.'))
                      : ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Image.asset('assets/img/man.png'),
                        title: Text(comments[index]['writer']),
                        subtitle: Text(comments[index]['content']),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    ]
      ),
    );
  }

}

