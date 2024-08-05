import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:lion12/user/view/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _memberIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _emailVerificationCodeController = TextEditingController();
  final TextEditingController _healthConController = TextEditingController();
  File? _image;
  bool _isEmailVerified = false;
  bool _isVerificationRequested = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileSize = await file.length();

      if (fileSize > 10 * 1024 * 1024) { // 파일 크기 제한을 10MB로 설정
        print('파일이 너무 큽니다. 10MB보다 작은 파일을 선택해주세요.');
        showDialog(
          context: context,
          builder: (BuildContext buildContext) {
            return AlertDialog(
              title: Text('파일이 너무 큽니다.'),
              content: Text('10MB보다 작은 파일을 선택해주세요.'),
              actions: [
                TextButton(
                  child: Text('확인'),
                  onPressed: () {
                    Navigator.of(buildContext).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      }

      setState(() {
        _image = file;
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_image == null) {
      print('이미지가 선택되지 않았습니다.');
      showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return AlertDialog(
            title: Text('오류'),
            content: Text('업로드할 이미지를 먼저 선택해주세요.'),
            actions: [
              TextButton(
                child: Text('확인'),
                onPressed: () {
                  Navigator.of(buildContext).pop();
                },
              ),
            ],
          );
        },
      );
      return null;
    }

    String imageUrl = 'http://13.125.226.133/upload'; // 이미지 업로드 URL

    try {
      final request = http.MultipartRequest('POST', Uri.parse(imageUrl));
      final mimeTypeData = lookupMimeType(_image!.path)!.split('/');

      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // 서버에서 요구하는 필드 이름
          _image!.path,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        print('이미지 업로드 성공');
        final responseString = await response.stream.bytesToString();
        final responseJson = json.decode(responseString);
        return responseJson['url'];
      } else {
        print('이미지 업로드 실패. 오류 코드: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('이미지 업로드 중 오류 발생: $e');
      return null;
    }
  }

  Future<void> _sendVerificationEmail() async {
    String email = _emailController.text;

    if (email.isEmpty) {
      _showErrorDialog('이메일을 입력해주세요.');
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showErrorDialog('올바른 이메일 형식을 입력해주세요.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://13.125.226.133/api/mailSend'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isVerificationRequested = true;
        });
        _showInfoDialog('인증 이메일이 발송되었습니다.');
      } else {
        _showErrorDialog('이메일 전송 실패. 오류 코드: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('이메일 전송 중 오류 발생: $e');
    }
  }

  Future<void> _verifyEmailCode() async {
    String email = _emailController.text;
    String verificationCode = _emailVerificationCodeController.text;

    if (verificationCode.isEmpty) {
      _showErrorDialog('인증 코드를 입력해주세요.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://13.125.226.133/api/mailauthCheck'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'email': email, 'authNum': verificationCode}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isEmailVerified = true;
        });
        _showInfoDialog('이메일 인증이 완료되었습니다.');
      } else {
        _showErrorDialog('인증 실패. 오류 코드: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('인증 중 오류 발생: $e');
    }
  }

  Future<void> _register(BuildContext buildContext) async {
    String memberId = _memberIdController.text;
    String password = _passwordController.text;
    String name = _nameController.text;
    String nickname = _nicknameController.text;
    String email = _emailController.text;
    String healthCon = _healthConController.text;

    if (memberId.isEmpty ||
        password.isEmpty ||
        name.isEmpty ||
        nickname.isEmpty ||
        email.isEmpty ||
        healthCon.isEmpty) {
      _showErrorDialog('모든 필드를 입력해주세요.');
      return;
    }

    if (password.length < 8) {
      _showErrorDialog('비밀번호는 8자리 이상이어야 합니다.');
      return;
    }

    if (!_isEmailVerified) {
      _showErrorDialog('이메일 인증이 완료되지 않았습니다.');
      return;
    }

    String? profilePicUrl = await _uploadImage();

    try {
      final body = json.encode({
        "memberId": memberId,
        "name": name,
        "password": password,
        "nickname": nickname,
        "profile_pic": profilePicUrl,
        "email": email,
        "health_con": healthCon,
      });

      final response = await http.post(
        Uri.parse('http://13.125.226.133/api/sign-up'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        Navigator.push(
          buildContext,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        print('회원 가입 성공');
        print('응답 본문: ${response.body}');
      } else {
        _showErrorDialog('회원 가입 실패. 오류 코드: ${response.statusCode}');
        print('응답 본문: ${response.body}');
      }
    } catch (e) {
      _showErrorDialog('회원 가입 중 오류 발생: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext buildContext) {
        return AlertDialog(
          title: Text('오류'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(buildContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext buildContext) {
        return AlertDialog(
          title: Text('정보'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(buildContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원 가입'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null ? Icon(Icons.add_a_photo, size: 50) : null,
                ),
              ),
              ElevatedButton(
                onPressed: _uploadImage,
                child: Text('사진 업로드하기'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _memberIdController,
                decoration: InputDecoration(
                  hintText: '아이디',
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: '비밀번호',
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: '이름',
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  hintText: '닉네임',
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: '이메일',
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailVerificationCodeController,
                decoration: InputDecoration(
                  hintText: '인증 코드',
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _healthConController,
                decoration: InputDecoration(
                  hintText: '건강 상태',
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendVerificationEmail,
                child: Text('이메일 인증 요청'),
              ),
              ElevatedButton(
                onPressed: _verifyEmailCode,
                child: Text('인증 코드 확인'),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  _register(context);
                },
                child: Image.asset(
                  'assets/img/login_button.png',
                  width: 250,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
