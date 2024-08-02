import 'package:flutter/cupertino.dart';
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

      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '                          닉네임님을 위한\n                         오늘의 추천 요리',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTag('#만성피로'),
                      _buildTag('#당뇨'),
                      _buildTag('#고혈압'),
                    ],
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '🎉 요리 이름 🎉',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 150,
                          color: Colors.grey[300],
                          child: Center(
                            child: Text('요리 이미지'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildSectionTitle('                            🥗 요리 재료 🥗'),
                  _buildIngredientList(),
                  _buildSectionTitle('                              🍳 조리법 🍳'),
                  _buildCookingSteps(),
                  SizedBox(height: 16),
                  _buildButtons(), // 버튼들이 중앙 정렬되도록
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Chip(
        label: Text(tag),
        backgroundColor: Colors.lightBlue[50],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 21,              // 텍스트 크기
          fontWeight: FontWeight.bold, // 텍스트 굵기
          color: Colors.black54,        // 텍스트 색깔
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildIngredientList() {
    return Column(
      children: List.generate(10, (index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Text('${index + 1}'),
              ),
              SizedBox(width: 16), // CircleAvatar와 재료명 텍스트 사이의 간격
              Text(
                '재료명',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(width: 8), // 재료명 텍스트와 이미지 사이의 간격
              Image.asset(
                'assets/img/rcm2.png', // 이미지를 지정하는 경로
                width: 40, // 이미지 너비
                height: 40, // 이미지 높이
              ),
              SizedBox(width: 16), // 이미지와 100g 텍스트 사이의 간격
              Text('100g'),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCookingSteps() {
    return Column(
      children: List.generate(10, (index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.orange[100],
            child: Text('${index + 1}'),
          ),
          title: Text('조리법'),
        );
      }),
    );
  }

  Widget _buildButtons() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {},
            child: Image.asset('assets/img/cs.png'),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () {},
            child: Image.asset('assets/img/rcm.png'),
          ),
        ],
      ),
    );
  }
}
