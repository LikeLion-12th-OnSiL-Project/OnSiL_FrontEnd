import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lion12/view/walk/walk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  _MyCoursesScreenState createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  List<dynamic> _courses = [];
  bool _isLoading = true; // 로딩 상태를 관리하는 변수

  @override
  void initState() {
    super.initState();
    _fetchMyCourses();
  }

  Future<void> _fetchMyCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      print('토큰을 찾을 수 없습니다.');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://13.125.226.133/location/my-locations'), // URL 수정
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _courses = jsonDecode(utf8.decode(response.bodyBytes));
          _isLoading = false; // 로딩 상태 업데이트
        });
      } else {
        throw Exception('Failed to load courses');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false; // 로딩 상태 업데이트
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내가 작성한 산책코스'),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: Image.asset('assets/img/logo2.png', width: 40, height: 40), // 이미지 크기 조정
          ),
        ],
      ),
      body: Container(
        color: Colors.white, // 배경색 흰색으로 설정
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _courses.isEmpty
            ? Center(child: Text('작성한 산책코스가 없습니다.'))
            : ListView.builder(
          itemCount: _courses.length,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.lightBlue[50], // 카드 배경색 하늘색으로 설정
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                title: Text(_courses[index]['title']),
                subtitle: Text('작성자: ${_courses[index]['writer']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(post: _courses[index]), // DetailPage로 이동
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
