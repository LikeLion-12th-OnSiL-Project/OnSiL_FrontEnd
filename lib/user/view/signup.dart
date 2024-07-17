import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lion12/user/view/login_screen.dart';

class SignupScreen extends StatelessWidget {
  final TextEditingController _memberIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Future<void> _register(BuildContext context) async {
    String url = 'http://43.201.112.183/api/sign-up';
    String memberId = _memberIdController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String name = _nameController.text;

    try {
      var response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          'memberId': memberId,
          'email': email,
          'password': password,
          'name': name,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      } else {
        print('Failed to register. Error: ${response.statusCode}');
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _memberIdController,
              decoration: InputDecoration(
                hintText: 'Member ID',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Email',
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
            ElevatedButton(
              onPressed: () {
                _register(context);
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
