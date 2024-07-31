import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path; // 'path' 패키지를 'path'로 별칭
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
  File? _image;

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
        // 응답에서 이미지 URL을 추출합니다
        final responseJson = json.decode(responseString);
        return responseJson['url']; // 응답 구조에 따라 조정 필요
      } else {
        print('이미지 업로드 실패. 오류 코드: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('이미지 업로드 중 오류 발생: $e');
      return null;
    }
  }

  Future<void> _register(BuildContext buildContext) async {
    String url = 'http://13.125.226.133/api/sign-up'; // 회원 가입용 URL
    String memberId = _memberIdController.text;
    String password = _passwordController.text;
    String name = _nameController.text;
    String nickname = _nicknameController.text;
    String email = _emailController.text;

    String? profilePicUrl = await _uploadImage();

    try {
      final body = json.encode({
        "memberId": memberId,
        "name": name,
        "password": password,
        "nickname": nickname,
        "profile_pic": profilePicUrl,
        "email": email,
      });

      final response = await http.post(
        Uri.parse(url),
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
        print('회원 가입 실패. 오류 코드: ${response.statusCode}');
        print('응답 본문: ${response.body}');
      }
    } catch (e) {
      print('회원 가입 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원 가입'),
      ),
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
              SizedBox(height: 20),
              TextField(
                controller: _memberIdController,
                decoration: InputDecoration(
                  hintText: '아이디',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: '비밀번호',
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: '이름',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  hintText: '닉네임',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: '이메일',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _register(context); // 회원 가입 API 호출
                },
                child: Text('회원 가입'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _uploadImage(); // 이미지 업로드 API 호출
                },
                child: Text('사진 업로드하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
