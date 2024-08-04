import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lion12/view/community.dart';
import 'package:lion12/view/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:lion12/component/text_field.dart';
import 'package:lion12/user/view/signup.dart';
import 'dart:async';

import '../../view/root.dart';

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
                SizedBox(height: 70),
                Container(
                  width: 180, // 원하는 너비 설정
                  height: 180, // 원하는 높이 설정
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/img/logo1.png'),
                      fit: BoxFit.cover, // BoxFit 옵션을 선택하세요.
                    ),
                  ),
                ),
                // 두 이미지 사이 간격 조절
                // 두 번째 로고 이미지
                Container(
                  width: 400, // 원하는 너비 설정
                  height: 400, // 원하는 높이 설정
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/img/homes.png'),
                      // BoxFit 옵션을 선택하세요.
                    ),
                  ),
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
  const LoginScreen1({super.key});

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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFFFFFFF),
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
                  SizedBox(height: 50),
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/img/logo2.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  TextField(
                    controller: _memberIdController,
                    decoration: InputDecoration(
                      hintText: '아이디 입력',
                      hintStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)), // 둥근 테두리
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)), // 둥근 테두리
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: '비밀번호 입력',
                      hintStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)), // 둥근 테두리
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)), // 둥근 테두리
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity, // 부모의 너비만큼 사용
                    child: GestureDetector(
                      onTap: _login,
                      child: Container(
                        width: 600, // 원하는 너비로 설정
                        child: Image.asset(
                          'assets/img/login_button.png',
                          fit: BoxFit.contain, // 이미지가 설정된 너비에 맞게 축소 또는 확대
                        ),
                      ),
                    ),
                  ),


                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                    child: Container(
                      width: 600, // 원하는 너비로 설정
                      child: Image.asset(
                        'assets/img/signup2.png',
                        fit: BoxFit.contain, // 이미지가 설정된 너비에 맞게 축소 또는 확대
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}