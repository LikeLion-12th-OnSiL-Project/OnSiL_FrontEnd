import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailPage extends StatefulWidget {
  final int postId;

  const DetailPage({required this.postId, Key? key}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Map<String, dynamic>? post;
  int helpCount = 0;
  bool isHelped = false;

  @override
  void initState() {
    super.initState();
    fetchPostDetail();
  }

  Future<void> fetchPostDetail() async {
    final url = 'http://13.125.226.133/onsil/board/${widget.postId}';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        post = jsonDecode(utf8.decode(response.bodyBytes));
        helpCount = post?['helpCount'] ?? 0;
      });
    } else {
      print('게시물 상세 정보를 불러오는 데 실패했습니다: ${response.statusCode}');
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
          : Padding(
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
              title: Text(post?['username'] ?? 'Unknown'),
              subtitle: Text('${DateTime.parse(post?['date'] ?? DateTime.now().toString()).difference(DateTime.now()).inMinutes.abs()}분 전'),
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Image.asset(
                        'assets/img/heart.png',
                        width: 20,
                        height: 20,
                        color: post?['liked'] ? Colors.red : Colors.black,
                      ),
                      onPressed: () {
                        // 좋아요 버튼 로직
                      },
                    ),
                    Text('${post?['likes']}'),
                  ],
                ),
                SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Image.asset(
                        'assets/img/chat.png',
                        width: 20,
                        height: 20,
                      ),
                      onPressed: () {
                        // 댓글 버튼 로직
                      },
                    ),
                    Text('${post?['comments']}'),
                  ],
                ),
                SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Image.asset(
                        'assets/img/share.png',
                        width: 20,
                        height: 20,
                      ),
                      onPressed: () {
                        // 공유 버튼 로직
                      },
                    ),
                    Text('${post?['shares']}'),
                  ],
                ),
              ],
            ),
            Divider(color: Colors.grey[300]),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '댓글 00',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(color: Colors.grey[300]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.reply, size: 20),
                    SizedBox(width: 4),
                    Text('답글 달기', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 16),
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
                Icon(Icons.more_vert, size: 20),
              ],
            ),
            Spacer(),
            TextField(
              decoration: InputDecoration(
                hintText: '댓글을 입력해주세요.',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
