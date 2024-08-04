import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'map.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<dynamic> _courses = [];
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  String _apiKey = 'AIzaSyDV8lz2OkQK8zsSo3Y8S78SgNfJR9HJTMg';

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    final response = await http.get(Uri.parse('http://13.125.226.133/location'));
    if (response.statusCode == 200) {
      setState(() {
        _courses = json.decode(response.body);
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
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _courses.length,
                itemBuilder: (context, index) {
                  return RecommendedCourseCard(
                    title: _courses[index]['title'],
                    startDistance: '출발지점 ${_courses[index]['start_latitude']}m',
                    courseLength: '코스길이 ${_courses[index]['end_latitude']}Km',
                    imageUrl: 'assets/course${index + 1}.jpg',
                  );
                },
              ),
            ),
            Divider(),
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

class RecommendedCourseCard extends StatelessWidget {
  final String title;
  final String startDistance;
  final String courseLength;
  final String imageUrl;

  RecommendedCourseCard({
    required this.title,
    required this.startDistance,
    required this.courseLength,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 코스 카드 클릭 시 동작 추가
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.asset(
                imageUrl,
                width: 150,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(startDistance),
                  Text(courseLength),
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
  int _likes = 0; // 초기 좋아요 수
  bool _isLiked = false; // 좋아요 상태
  int _comments = 0;
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};

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

  @override
  void initState() {
    super.initState();
    _likes = widget.post['likes'];
    _comments = widget.post['replies'];
    _addRoute();
  }

  void _addRoute() {
    setState(() {
      _polylines.add(Polyline(
        polylineId: PolylineId('route'),
        points: [
          LatLng(widget.post['start_latitude'].toDouble(), widget.post['start_longitude'].toDouble()),
          LatLng(widget.post['end_latitude'].toDouble(), widget.post['end_longitude'].toDouble()),
        ],
        color: Colors.blue,
        width: 5,
      ));
    });
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
            SizedBox(height: 8),
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
                polylines: _polylines,
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
  int helpCount = 0;
  bool isHelped = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            // 댓글 리스트 추가
            Expanded(
              child: ListView.builder(
                itemCount: 5, // 샘플 데이터 수
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Image.asset('assets/img/man.png'),
                    title: Text('댓글 작성자 $index'),
                    subtitle: Text('댓글 내용 $index'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}