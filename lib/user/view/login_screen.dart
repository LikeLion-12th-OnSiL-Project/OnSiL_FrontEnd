import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lion12/view/community.dart';
import 'package:lion12/view/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:lion12/component/text_field.dart';
import 'package:lion12/user/view/signup.dart';
import 'dart:async';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    // 3초 후에 LoginScreen1으로 이동
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => LoginScreen1(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: Container(
          // 배경 화면
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1E90FF),
                Color(0xFF1E90FF), // 중간 파란색
                Color(0xFFFFFFFF),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 첫 번째 로고 이미지
                SizedBox(height: 5),
                Image.asset(
                  'assets/img/logo1.png',
                  width: 200, // 원하는 로고의 너비 설정
                  height: 200, // 원하는 로고의 높이 설정
                ),
                SizedBox(height: 5), // 두 이미지 사이 간격 조절
                // 두 번째 로고 이미지
                Image.asset(
                  'assets/img/homes.png',
                  width: 300, // 원하는 로고의 너비 설정
                  height: 300, // 원하는 로고의 높이 설정
                ),
                SizedBox(height: 10), // 두 이미지와 이메일 입력 칸 사이 간격 조절
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginScreen1 extends StatefulWidget {
  @override
  _LoginScreen1State createState() => _LoginScreen1State();
}

class _LoginScreen1State extends State<LoginScreen1> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    final response = await http.post(
      Uri.parse('http://43.201.112.183/api/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'memberId': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      print('Login successful');
      print('Response body: ${response.body}');

      // TODO: 로그인 성공 후 페이지 이동 또는 토큰 저장 등의 작업 수행
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    } else {
      print('Login failed: ${response.statusCode}');
      // TODO: 사용자에게 오류 메시지 표시
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: Container(
          // 배경 화면
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1E90FF),
                Color(0xFF1E90FF), // 중간 파란색
                Color(0xFFFFFFFF),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 첫 번째 로고 이미지
                Image.asset(
                  'assets/img/logo1.png',
                  width: 180, // 원하는 로고의 너비 설정
                  height: 180, // 원하는 로고의 높이 설정
                ),
                SizedBox(height: 10), // 두 이미지 사이 간격 조절
                // 두 번째 로고 이미지
                Image.asset(
                  'assets/img/homes.png',
                  width: 300, // 원하는 로고의 너비 설정
                  height: 300, // 원하는 로고의 높이 설정
                ),
                SizedBox(height: 10), // 두 이미지와 이메일 입력 칸 사이 간격 조절

                //카카오톡 로그인
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupScreen()),
                    );
                  },
                  child: Image.asset(
                    'assets/img/login.png',
                    width: 500,
                  ),
                ),
                TextButton(
                  onPressed: _login,
                  child: Text('회원 탈퇴'),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: _login,
                  child: Text('가입한 계정이 기억나지 않나요?'),
                ),
                SizedBox(height: 10),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
