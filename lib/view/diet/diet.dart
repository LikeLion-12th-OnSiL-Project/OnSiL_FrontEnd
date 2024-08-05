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
  String _token = '';
  String _nickname = '닉네임';
  List<String> _healthConditions = [];
  List<String> _headerItems = [];
  List<String> _dietItems = [];

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchData();
  }

  Future<void> _loadTokenAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';

    await _fetchUserData();
    _fetchDietData();
  }

  Future<void> _fetchUserData() async {
    final url = Uri.parse('http://13.125.226.133/api/mypage');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        // Decode the response using UTF-8
        final decodedResponse = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedResponse);
        setState(() {
          _nickname = data['nickname'] ?? '닉네임';
          _healthConditions = (data['health_con'] ?? '').split(',');
        });
      } else {
        setState(() {
          _response = '오류: ${response.statusCode} - ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _response = '오류: $e';
      });
    }
  }

  Future<void> _fetchDietData() async {
    final url = Uri.parse('http://13.125.226.133/api/v1/chatGpt/prompt/yourdiet');

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
        final decodedResponse = utf8.decode(response.bodyBytes);
        final lines = decodedResponse.split('\n').where((line) => line.isNotEmpty).toList();

        List<String> headerItems = [];
        List<String> dietItems = [];

        for (var line in lines) {
          if (RegExp(r'^\d').hasMatch(line)) {
            dietItems.add(line);
          } else {
            headerItems.add(line);
          }
        }

        setState(() {
          _headerItems = headerItems;
          _dietItems = dietItems;
          _response = '상태 코드: ${response.statusCode}';
        });
      } else {
        setState(() {
          _response = '오류: ${response.statusCode} - ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _response = '오류: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  Text(
                    '$_nickname님을 위한\n오늘의 추천 식료품',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 5.0,
                    children: _healthConditions.map((condition) => Chip(label: Text(condition))).toList(),
                  ),
                  SizedBox(height: 10),
                  ..._headerItems.map((item) => Text(
                    item,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  )),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🥦 추천 🥦',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  _dietItems.isEmpty
                      ? Center(child: Text(_response))
                      : ListView.builder(
                    shrinkWrap: true, // Use shrinkWrap to avoid unbounded height error
                    physics: NeverScrollableScrollPhysics(), // Disable ListView's own scrolling
                    itemCount: _dietItems.length,
                    itemBuilder: (context, index) {
                      final item = _dietItems[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            child: Text('${index + 1}'),
                          ),
                          title: Text(item),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}