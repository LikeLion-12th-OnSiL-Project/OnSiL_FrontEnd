import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DetailPage extends StatefulWidget {
  final int postId;

  const DetailPage({required this.postId, Key? key}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Map<String, dynamic>? post;
  List<Map<String, dynamic>> comments = [];
  int helpCount = 0;
  bool isHelped = false;
  final TextEditingController _commentController = TextEditingController();
  String? nickname; // 사용자 닉네임 저장 변수

  @override
  void initState() {
    super.initState();
    fetchUserNickname(); // 사용자 닉네임 가져오기
    fetchPostDetail();
    fetchComments();
  }

  Future<void> fetchUserNickname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print('사용자 토큰이 없습니다.');
      return;
    }

    final url = 'http://13.125.226.133/user/me'; // 사용자 정보 가져오는 API 엔드포인트
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        nickname = data['nickname']; // 닉네임 설정
      });
    } else {
      print('사용자 정보를 불러오는 데 실패했습니다: ${response.statusCode}');
    }
  }

  Future<void> fetchPostDetail() async {
    final url = 'http://13.125.226.133/onsil/board/search/${widget.postId}';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        post = jsonDecode(utf8.decode(response.bodyBytes));
        helpCount = post?['recommend'] ?? 0;
      });
    } else {
      print('게시물 상세 정보를 불러오는 데 실패했습니다: ${response.statusCode}');
    }
  }

  Future<void> fetchComments() async {
    final url = 'http://13.125.226.133/board-reply/${widget.postId}';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      print('서버 응답: $responseData'); // 응답 데이터 로깅

      setState(() {
        comments.clear(); // 댓글 리스트를 초기화하여 다른 게시물의 댓글이 남아 있지 않도록 합니다.
        if (responseData is Map<String, dynamic>) {
          comments.add(responseData);
        } else if (responseData is List) {
          comments = List<Map<String, dynamic>>.from(responseData);
        } else {
          comments = []; // 기본적으로 빈 리스트
          print('알 수 없는 응답 구조입니다.');
        }
      });
    } else {
      print('댓글을 불러오는 데 실패했습니다: ${response.statusCode}');
    }
  }

  Future<void> _postComment() async {
    if (nickname == null) {
      print('닉네임을 가져올 수 없습니다.');
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print('작성자 토큰이 없습니다.');
      return;
    }

    final url = 'http://13.125.226.133/board-reply/${widget.postId}';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'writer': nickname, // 닉네임을 writer로 사용
        'content': _commentController.text,
        'boardId': widget.postId,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        comments.add({
          'writer': nickname, // 서버 응답 대신 클라이언트에서 바로 닉네임을 사용
          'content': _commentController.text,
          'boardId': widget.postId,
        });
        _commentController.clear(); // 댓글 입력 후 텍스트필드 초기화
      });
      print('댓글이 성공적으로 등록되었습니다.');
    } else {
      print('댓글 등록에 실패했습니다: ${response.statusCode}');
    }
  }

  void _toggleHelp() {
    setState(() {
      if (isHelped) {
        helpCount--;
      } else {
        helpCount++;
      }
      isHelped = !isHelped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // 키보드에 맞춰 UI 조정
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: Image.asset('assets/img/bell.png'),
            onPressed: () {},
          ),
        ],
      ),
      body: post == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Image.asset('assets/img/man.png'),
                ),
                title: Text(post?['writerNickname'] ?? 'Unknown'),
                subtitle: Text('카테고리: ${post?['category'] ?? 'Unknown'}'),
              ),
              SizedBox(height: 8.0),
              Text(
                post?['title'] ?? '제목 없음',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                post?['content'] ?? '내용 없음',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16.0),
              if (post?['image'] != null && post!['image'].isNotEmpty)
                Image.network(
                  post!['image'],
                  height: 200,
                  fit: BoxFit.cover,
                ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  GestureDetector(
                    onTap: _toggleHelp,
                    child: Row(
                      children: [
                        Icon(
                          isHelped ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: isHelped ? Colors.red : null,
                        ),
                        SizedBox(width: 4),
                        Text('도움 돼요 $helpCount', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.grey[300]),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '댓글 ${comments.length}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(color: Colors.grey[300]),
              ...comments.map((comment) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment['writer'] ?? 'Unknown',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(comment['content'] ?? ''),
                          ],
                        ),
                      ),
                      Icon(Icons.more_vert, size: 20),
                    ],
                  ),
                );
              }).toList(),
              SizedBox(height: 16.0),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: '댓글을 입력해주세요.',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _postComment,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
