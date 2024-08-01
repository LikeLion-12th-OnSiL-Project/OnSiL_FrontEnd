import 'package:flutter/material.dart';
import 'package:lion12/view/post.dart';
import 'detail.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> posts = [
    {
      'username': '닉네임',
      'time': DateTime.now().subtract(Duration(minutes: 1)),
      'likes': 126,
      'comments': 5,
      'shares': 5,
      'content': '모든 국민은 보건에 관하여...',
      'liked': false,  // 좋아요 상태 추가
    },
    {
      'username': '닉네임',
      'time': DateTime.now().subtract(Duration(minutes: 5)),
      'likes': 200,
      'comments': 10,
      'shares': 15,
      'content': '모든 국민은 보건에 관하여...',
      'liked': false,  // 좋아요 상태 추가
    },
    {
      'username': '닉네임',
      'time': DateTime.now().subtract(Duration(minutes: 10)),
      'likes': 50,
      'comments': 1,
      'shares': 0,
      'content': '모든 국민은 보건에 관하여...',
      'liked': false,  // 좋아요 상태 추가
    },
    // 더미 데이터 추가 가능
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  List<Map<String, dynamic>> getSortedPosts(String type) {
    if (type == 'latest') {
      posts.sort((a, b) => b['time'].compareTo(a['time']));
    } else if (type == 'popular') {
      posts.sort((a, b) => b['likes'].compareTo(a['likes']));
    }
    return posts;
  }

  void _toggleLike(int index) {
    setState(() {
      posts[index]['liked'] = !posts[index]['liked'];
      if (posts[index]['liked']) {
        posts[index]['likes'] += 1;
      } else {
        posts[index]['likes'] -= 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: [
                Tab(text: '최신글'),
                Tab(text: '인기글'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildPostList(getSortedPosts('latest')),
                buildPostList(getSortedPosts('popular')),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => WritePostPage()));
        },
        child: Image.asset(
            'assets/img/add.png'
        ),
      ),
    );
  }

  Widget buildPostList(List<Map<String, dynamic>> posts) {
    return ListView.separated(
      itemCount: posts.length,
      separatorBuilder: (context, index) => Divider(
        color: Colors.grey[300], // 구분선 색상
        thickness: 1.0, // 구분선 두께
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPage(post: posts[index]),
              ),
            );
          },
          child: Container(
            color: Colors.grey[100], // 게시글 배경색을 회색으로 설정
            child: Card(
              margin: EdgeInsets.zero, // Card 위젯의 외부 여백 제거
              color: Colors.white, // Card 배경색 흰색으로 설정
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Image.asset(
                          'assets/img/man.png',
                        ),
                      ),
                      title: Text(posts[index]['username']),
                      subtitle: Text('${posts[index]['time'].difference(DateTime.now()).inMinutes.abs()}분 전'),
                      trailing: Icon(Icons.more_vert),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(posts[index]['content']),
                    ),
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
                                color: posts[index]['liked'] ? Colors.red : Colors.black,
                              ),
                              onPressed: () {
                                _toggleLike(index);
                              },
                            ),
                            SizedBox(width: 8), // 아이콘과 숫자 사이의 간격 조정
                            Text('${posts[index]['likes']}'),
                          ],
                        ),
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
                            SizedBox(width: 8), // 아이콘과 숫자 사이의 간격 조정
                            Text('${posts[index]['comments']}'),
                          ],
                        ),
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
                            SizedBox(width: 8), // 아이콘과 숫자 사이의 간격 조정
                            Text('${posts[index]['shares']}'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


