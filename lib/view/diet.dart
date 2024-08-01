import 'package:flutter/material.dart';

class Diet extends StatefulWidget {
  const Diet({super.key});

  @override
  State<Diet> createState() => _DietState();
}

class _DietState extends State<Diet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 하얀색으로 설정
      body: Center(
        child: Text(
          'Diet',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // 폰트 스타일 추가
        ),
      ),
    );
  }
}

