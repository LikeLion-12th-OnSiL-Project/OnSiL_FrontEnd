import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

import '../../view/root.dart';
import 'package:lion12/user/view/signup.dart';
import 'package:lion12/component/text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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
                SizedBox(height: 50),
                Image.asset(
                  'assets/img/logo1.png',
                  width: 150, // 원하는 로고의 너비 설정
                  height: 150, // 원하는 로고의 높이 설정
                ),
                SizedBox(height: 20), // 두 이미지 사이 간격 조절
                // 두 번째 로고 이미지
                Image.asset(
                  'assets/img/homes.png',
                  width: 200, // 원하는 로고의 너비 설정
                  height: 200, // 원하는 로고의 높이 설정
                ),
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
  final TextEditingController _memberIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _memberIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    String url = 'http://13.125.226.133/api/login'; // 로그인용 URL
    String memberId = _memberIdController.text;
    String password = _passwordController.text;

    try {
      final body = json.encode({
        "memberId": memberId,
        "password": password,
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token']; // 서버 응답에서 토큰 추출

        // 토큰을 SharedPreferences에 저장
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RootTab()),
        );
      } else {
        print('로그인 실패. 오류 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('로그인 중 오류 발생: $e');
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 첫 번째 로고 이미지
                  SizedBox(height: 50),
                  Image.asset(
                    'assets/img/logo1.png',
                    width: 150, // 원하는 로고의 너비 설정
                    height: 150, // 원하는 로고의 높이 설정
                  ),
                  SizedBox(height: 20), // 두 이미지 사이 간격 조절
                  // 두 번째 로고 이미지
                  Image.asset(
                    'assets/img/homes.png',
                    width: 200, // 원하는 로고의 너비 설정
                    height: 200, // 원하는 로고의 높이 설정
                  ),
                  SizedBox(height: 40), // 두 이미지와 이메일 입력 칸 사이 간격 조절
                  CustomTextFormField(
                    hintText: 'MemberId',
                    controller: _memberIdController,
                    onChanged: (value) {},
                  ),
                  SizedBox(height: 20),
                  CustomTextFormField(
                    hintText: 'Password',
                    obscureText: true,
                    controller: _passwordController,
                    onChanged: (value) {},
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity, // 버튼을 화면 너비에 맞춤
                    child: ElevatedButton(
                      onPressed: _login,
                      child: Text('Login'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
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
                      width: 250,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: _login,
                    child: Text('회원 탈퇴'),
                  ),
                  // SizedBox(height: 10),
                  TextButton(
                    onPressed: _login,
                    child: Text('가입한 계정이 기억나지 않나요?'),
                  ),
                  // SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
