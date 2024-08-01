import 'package:flutter/material.dart';
import 'package:lion12/view/map.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 전체 배경색을 하얀색으로 설정
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
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  RecommendedCourseCard(
                    title: '추천 코스1',
                    startDistance: '출발지점 200m',
                    courseLength: '코스길이 5.5Km',
                    imageUrl: 'assets/course1.jpg',
                  ),
                  RecommendedCourseCard(
                    title: '추천 코스2',
                    startDistance: '출발지점 200m',
                    courseLength: '코스길이 5.5Km',
                    imageUrl: 'assets/course2.jpg',
                  ),
                  RecommendedCourseCard(
                    title: '추천 코스3',
                    startDistance: '출발지점 200m',
                    courseLength: '코스길이 5.5Km',
                    imageUrl: 'assets/course3.jpg',
                  ),
                ],
              ),
            ),
            Divider(),
            WalkPost(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => MapWidget()));
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
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
          color: Colors.white, // 카드 배경색을 하얀색으로 설정
          borderRadius: BorderRadius.circular(8),
          boxShadow: [ // 카드에 그림자를 추가하여 시각적으로 분리
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // 그림자의 위치
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
  @override
  _WalkPostState createState() => _WalkPostState();
}

class _WalkPostState extends State<WalkPost> {
  int _likes = 126; // 초기 좋아요 수
  bool _isLiked = false; // 좋아요 상태

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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text('김'),
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('김순자님', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('천호지 한 바퀴 코스 +5km'),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              // 지도 이미지 클릭 시 동작 추가
            },
            child: Container(
              height: 200,
              color: Colors.white, // 지도 이미지 배경색을 하얀색으로 설정
              child: Center(
                child: Text('지도 이미지'),
              ),
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
                      _isLiked ? 'assets/img/heart.png' : 'assets/img/heart.png', // 좋아요 버튼 이미지 경로
                      width: 24, // 버튼 크기 조절
                      height: 24,
                      color: _isLiked ? Colors.red : Colors.black,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text('$_likes'), // 좋아요 수 표시
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      // 댓글 기능 추가
                    },
                    child: Image.asset(
                      'assets/img/commu.png', // 댓글 버튼 이미지 경로
                      width: 24, // 버튼 크기 조절
                      height: 24,
                    ),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      // 공유 기능 추가
                    },
                    child: Image.asset(
                      'assets/img/share.png', // 공유 버튼 이미지 경로
                      width: 24, // 버튼 크기 조절
                      height: 24,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.more_horiz),
                onPressed: () {
                  // 더보기 기능 추가
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
