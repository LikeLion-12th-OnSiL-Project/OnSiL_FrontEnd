import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Mypage extends StatefulWidget {
  const Mypage({super.key});

  @override
  _MypageState createState() => _MypageState();
}

class _MypageState extends State<Mypage> {
  String? nickname;
  String? profilePicUrl;
  double _sliderValue = 1; // 슬라이더 기본 값, 1은 기본 크기를 의미합니다.

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

    String url = 'http://13.125.226.133/api/mypage'; // 사용자 정보 가져오기 URL
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
        var data = jsonDecode(utf8.decode(response.bodyBytes));
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
    return SingleChildScrollView(
      child: Padding(
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
                        style: TextStyle(fontSize: _getTextSize(), fontWeight: FontWeight.bold),
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
      ),
    );
  }

  double _getTextSize() {
    // 슬라이더 값에 따라 글자 크기를 설정
    switch (_sliderValue.toInt()) {
      case 0:
        return 12; // 소
      case 1:
        return 16; // 중
      case 2:
        return 20; // 대
      default:
        return 16; // 기본 크기
    }
  }

  Widget _buildChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: Chip(
        label: Text(label, style: TextStyle(fontSize: _getTextSize() - 2)),
        backgroundColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildHealthStatus() {
    double healthTextSize = _getTextSize(); // 건강 상태 텍스트 크기 조정

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
        Align(
          alignment: Alignment.center,
          child: Text(
            '안서동 산책러님의 건강상태는\n‘꾸준한 관리 필요’ 상태입니다. 😌\n규칙적인 식사와 가벼운 걷기를 추천드려요.',
            style: TextStyle(fontSize: healthTextSize), // 동적으로 변경되는 건강 상태 텍스트 크기
            textAlign: TextAlign.center,
          ),
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
        Text('글자 크기', style: TextStyle(fontSize: 16)),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _sliderValue.toDouble(),
                min: 0,
                max: 2,
                divisions: 2, // 3단계로 나누기
                onChanged: (double value) {
                  setState(() {
                    _sliderValue = value;
                  });
                },
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('소', style: TextStyle(fontSize: _getTextSize() - 2)),
            Text('중', style: TextStyle(fontSize: _getTextSize())),
            Text('대', style: TextStyle(fontSize: _getTextSize() + 2)),
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
          Icon(icon, size: 20 * (_sliderValue + 0.5), color: Colors.grey),
          SizedBox(width: 10),
          Text('$label $count', style: TextStyle(fontSize: _getTextSize())),
        ],
      ),
    );
  }
}
