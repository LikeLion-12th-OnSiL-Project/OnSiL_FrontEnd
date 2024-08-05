import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart'; // flutter_html 패키지 추가
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ScrollController _likedCoursesController = ScrollController();
  final ScrollController _healthNewsController = ScrollController();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _keyword = '';
  List<dynamic> _newsData = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showKeywordDialog();
    });
  }

  Future<void> _showKeywordDialog() async {
    String keyword = '';
    await showDialog(
      context: context,
      barrierDismissible: false, // 다이얼로그 외부를 터치해도 닫히지 않도록 설정
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('키워드 입력'),
          content: TextField(
            onChanged: (value) {
              keyword = value;
            },
            decoration: InputDecoration(hintText: "키워드를 입력하세요"),
          ),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                setState(() {
                  _keyword = keyword;
                });
                Navigator.of(context).pop();
                _fetchNewsData(); // 키워드 입력 후 데이터를 가져옴
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchNewsData() async {
    final response = await http.get(
      Uri.parse('http://13.125.226.133/healthnews?keyword=$_keyword'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _newsData = jsonDecode(utf8.decode(response.bodyBytes));
      });
    } else {
      // 에러 처리
    }
  }

  void _scrollToNext(ScrollController controller) {
    controller.animateTo(
      controller.position.pixels + 160.0, // 아이템 너비만큼 스크롤
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색 하얀색
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageView(),
            _buildSectionTitle('좋아한 코스', _likedCoursesController),
            _buildHorizontalList(_likedCoursesController),
            _buildSectionTitle('오늘의 건강 뉴스', _healthNewsController),
            _buildVerticalList(_healthNewsController),
          ],
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return Container(
      height: 220.0,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: 5,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                width: 400.0,
                height: 200.0,
                margin: const EdgeInsets.all(16.0),
                color: Colors.grey[300],
                child: Center(
                  child: Text(
                    '큰 플레이스홀더 $index',
                    style: TextStyle(fontSize: 24.0),
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 8.0,
            right: 8.0,
            child: Text(
              '${_currentPage + 1}/5',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w300, // 글씨체를 얇게 설정
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ScrollController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () => _scrollToNext(controller),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(ScrollController controller) {
    return Container(
      height: 160.0,
      child: ListView.builder(
        controller: controller,
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 160.0,
            margin: const EdgeInsets.only(left: 16.0),
            color: Colors.grey[300],
            child: Center(
              child: Text('플레이스홀더 $index'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerticalList(ScrollController controller) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        controller: controller,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _newsData.length,
        itemBuilder: (context, index) {
          final newsItem = _newsData[index];
          final imageUrl = newsItem['imageUrl'];
          final title = newsItem['title'];
          final description = newsItem['description'];
          final link = newsItem['link'];

          // Validate if URL starts with http:// or https://
          if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover, // 이미지 비율 유지
                      height: 100.0, // 이미지 높이를 적절히 설정
                      width: double.infinity,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0), // 카드 내 여백 조정
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Html(
                          data: title,
                          style: {
                            'body': Style(
                              fontSize: FontSize(18.0),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          },
                        ),
                        SizedBox(height: 8.0),
                        Html(
                          data: description,
                          style: {
                            'body': Style(
                              fontSize: FontSize(16.0),
                              color: Colors.black54,
                            ),
                          },
                        ),
                        SizedBox(height: 12.0),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              _launchURL(link);
                            },
                            child: Text('자세히 보기', style: TextStyle(color: Colors.blue)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container(); // or you can show an error image/text
          }
        },
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }
}
