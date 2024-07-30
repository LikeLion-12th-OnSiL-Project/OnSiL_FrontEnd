import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart'; // Import this package for MediaType
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
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _register(BuildContext context) async {
    String url = 'http://43.201.112.183/api/sign-up';
    String memberId = _memberIdController.text;
    String password = _passwordController.text;
    String name = _nameController.text;
    String nickname = _nicknameController.text;

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['memberId'] = memberId;
      request.fields['password'] = password;
      request.fields['name'] = name;
      request.fields['nickname'] = nickname;

      if (_image != null) {
        final mimeTypeData = lookupMimeType(_image!.path)!.split('/');
        final imageUploadRequest = http.MultipartFile.fromBytes(
          'profile_pic',
          await _image!.readAsBytes(),
          filename: basename(_image!.path),
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
        );

        request.files.add(imageUploadRequest);
      }

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (responseData.statusCode == 200) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
        print('Registration successful');
        print('Response body: ${responseData.body}');
      } else {
        print('Failed to register. Error: ${responseData.statusCode}');
        print('Response body: ${responseData.body}');
      }
    } catch (e) {
      print('Error during registration: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
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
                  hintText: 'Member ID',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Password',
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Name',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  hintText: 'Nickname',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _register(context);
                },
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
