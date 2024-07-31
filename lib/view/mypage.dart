import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Mypage extends StatefulWidget {
  const Mypage({super.key});

  @override
  _MypageState createState() => _MypageState();
}

class _MypageState extends State<Mypage> {
  String? nickname;
  String? profilePicUrl;

  @override
  void initState() {
    super.initState();
    _fetchMemberInfo();
  }

  Future<void> _fetchMemberInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      print('토큰을 찾을 수 없습니다.');
      return;
    }

    String url = 'http://43.201.112.183/api'; // 사용자 정보 가져오기 URL
    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Fetch response status: ${response.statusCode}');
      print('Fetch response body: ${response.body}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          nickname = data['nickname'];
          profilePicUrl = data['profile_pic'];
        });
      } else {
        print('회원 정보 로드 실패. 오류 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('회원 정보 로드 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue,
                backgroundImage: profilePicUrl != null
                    ? NetworkImage(profilePicUrl!)
                    : null,
                child: profilePicUrl == null ? Icon(Icons.person, size: 30) : null,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nickname ?? '????',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildChip('#40대'),
                          _buildChip('#쿠쿠맘산책'),
                          _buildChip('#저녁산책'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
          SizedBox(height: 20),
          _buildHealthStatus(),
          SizedBox(height: 20),
          _buildSlider(),
          SizedBox(height: 20),
          _buildActivities(),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: Chip(
        label: Text(label, style: TextStyle(fontSize: 12)),
        backgroundColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildHealthStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildHealthButton('당뇨'),
            _buildHealthButton('고혈압'),
            _buildHealthButton('관절염'),
          ],
        ),
        SizedBox(height: 10),
        Text(
          '안서동 산책러님의 건강상태는\n‘꾸준한 관리 필요’ 상태입니다. 😌\n규칙적인 식사와 가벼운 걷기를 추천드려요.',
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildHealthButton(String label) {
    return TextButton(
      onPressed: () {
        // 버튼 클릭 시 동작
      },
      child: Text(label, style: TextStyle(color: Colors.blue)),
      style: TextButton.styleFrom(
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('글자크기', style: TextStyle(fontSize: 16)),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: 1,
                min: 0,
                max: 2,
                divisions: 2,
                onChanged: (double value) {
                  // 슬라이더 값 변경 시 동작
                },
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('소', style: TextStyle(fontSize: 12)),
            Text('중', style: TextStyle(fontSize: 12)),
            Text('대', style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildActivityRow(Icons.edit, '내가 작성한 산책코스', 0),
        _buildActivityRow(Icons.edit, '내가 작성한 게시물', 0),
        _buildActivityRow(Icons.favorite, '내가 좋아한 산책코스', 0),
        _buildActivityRow(Icons.favorite, '내가 좋아한 게시물', 0),
      ],
    );
  }

  Widget _buildActivityRow(IconData icon, String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          SizedBox(width: 10),
          Text('$label $count', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
