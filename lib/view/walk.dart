import 'package:flutter/material.dart';
import 'package:lion12/view/map.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
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

class WalkPost extends StatelessWidget {
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

            },
            child: Container(
              height: 200,
              color: Colors.grey[300],
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
                  IconButton(
                    icon: Icon(Icons.thumb_up),
                    onPressed: () {

                    },
                  ),
                  Text('126'),
                  IconButton(
                    icon: Icon(Icons.comment),
                    onPressed: () {

                    },
                  ),
                  Text('5'),
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {

                    },
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.more_horiz),
                onPressed: () {

                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
