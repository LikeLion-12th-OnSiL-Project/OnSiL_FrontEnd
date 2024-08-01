import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> post;

  const DetailPage({required this.post, Key? key}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int helpCount = 0;
  bool isHelped = false;

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
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
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
            icon: Image.asset('assets/img/bell.png',),
            onPressed: () {},
          ),
          // IconButton(
          //   icon: Icon(Icons.more_vert, color: Colors.black),
          //   onPressed: () {},
          // ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Image.asset(
                  'assets/img/man.png',
                ),
              ),
              title: Text(widget.post['username']),
              subtitle: Text('${widget.post['time'].difference(DateTime.now()).inMinutes.abs()}분 전'),
            ),
            SizedBox(height: 8.0),
            // Text(
            //   '제목',
            //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            // ),
            SizedBox(height: 8.0),
            Text(
              widget.post['content'],
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            Container(
              height: 200,
              color: Colors.grey[300],
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
                        color: widget.post['liked'] ? Colors.red : Colors.black,
                      ),
                      onPressed: () {
                        // 좋아요 버튼 로직
                      },
                    ),
                    Text('${widget.post['likes']}'),
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
                    Text('${widget.post['comments']}'),
                  ],
                ),
                SizedBox(width: 8),
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Image.asset(
                  'assets/img/man.png',
                ),
              ),
              title: Text(widget.post['username']),
              subtitle: Text('${widget.post['time'].difference(DateTime.now()).inMinutes.abs()}분 전\n댓글 내용'),
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
