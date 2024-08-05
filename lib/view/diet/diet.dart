import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Diet extends StatefulWidget {
  const Diet({super.key});

  @override
  State<Diet> createState() => _DietState();
}

class _DietState extends State<Diet> {
  String _response = '로딩 중...';
  String _statusCode = '';
  String _token = '';

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchData();
  }

  Future<void> _loadTokenAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';

    // 데이터 요청
    _fetchDietData();
  }

  Future<void> _fetchDietData() async {
    final url = Uri.parse('http://13.125.226.133/api/v1/chatGpt/prompt/yourdiet');

    print('API 요청 시작..');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        // UTF-8로 응답 디코딩
        final decodedResponse = utf8.decode(response.bodyBytes);
        print('API 요청 성공: $decodedResponse');
        setState(() {
          _response = decodedResponse;
          _statusCode = '상태 코드: ${response.statusCode}';
        });
      } else {
        print('API 요청 실패: ${response.statusCode} - ${response.reasonPhrase}');
        setState(() {
          _response = '오류: ${response.statusCode} - ${response.reasonPhrase}';
          _statusCode = '상태 코드: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('예외 발생: $e');
      setState(() {
        _response = '오류: $e';
        _statusCode = '상태 코드: 알 수 없음';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('식단 추천'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_statusCode),
              SizedBox(height: 10),
              Text(_response),
            ],
          ),
        ),
      ),
    );
  }
}
