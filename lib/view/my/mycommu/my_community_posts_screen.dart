import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lion12/view/community/detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MyCommunityPostsScreen extends StatefulWidget {
  const MyCommunityPostsScreen({super.key});

  @override
  _MyCommunityPostsScreenState createState() => _MyCommunityPostsScreenState();
}

class _MyCommunityPostsScreenState extends State<MyCommunityPostsScreen> {
  List<dynamic> _posts = [];
  bool _isLoading = true;
  String? nickname;

  @override
  void initState() {
    super.initState();
    _fetchUserNicknameAndPosts();
  }

  Future<void> _fetchUserNicknameAndPosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      print('토큰을 찾을 수 없습니다.');
      return;
    }

    try {
      // 사용자 정보 가져오기
      final userInfoResponse = await http.get(
        Uri.parse('http://13.125.226.133/api/mypage'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (userInfoResponse.statusCode == 200) {
        final userInfo = jsonDecode(utf8.decode(userInfoResponse.bodyBytes));
        nickname = userInfo['nickname'];
        print('사용자 닉네임: $nickname');
      } else {
        print('사용자 정보를 불러오는 데 실패했습니다: ${userInfoResponse.statusCode}');
        return;
      }

      // 모든 게시물 가져오기
      final postsResponse = await http.get(
        Uri.parse('http://13.125.226.133/onsil/board/list'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (postsResponse.statusCode == 200) {
        final postsData = jsonDecode(utf8.decode(postsResponse.bodyBytes))['content'] as List;
        _posts = postsData.where((post) => post['writerNickname'] == nickname).toList();
        print('필터링된 게시물: $_posts');
        setState(() {
          _isLoading = false;
        });
      } else {
        print('게시글을 불러오는 데 실패했습니다: ${postsResponse.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('오류 발생: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내가 작성한 게시물'),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 30.0),
            child: Image.asset('assets/img/logo2.png'),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _posts.isEmpty
            ? Center(child: Text('작성한 게시물이 없습니다.'))
            : ListView.builder(
          itemCount: _posts.length,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.lightBlue[50],
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                title: Text(_posts[index]['title']),
                subtitle: Text('작성자: ${_posts[index]['writerNickname']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(postId: _posts[index]['postId']),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
//view -> my -> mycommu -> my_community_posts_screen.dart