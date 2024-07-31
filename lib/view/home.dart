import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ScrollController _recentCoursesController = ScrollController();
  final ScrollController _likedCoursesController = ScrollController();
  final ScrollController _healthNewsController = ScrollController();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _scrollToNext(ScrollController controller) {
    controller.animateTo(
      controller.position.pixels + 160.0, // 한 아이템 너비만큼 스크롤
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 바탕화면 색상을 하얀색으로 변경
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageView(),
            _buildSectionTitle('최근 걸은 코스', _recentCoursesController),
            _buildHorizontalList(_recentCoursesController),
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
                fontWeight: FontWeight.w300, // 글씨체를 가늘게 설정
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
      height: 660.0, // 220 * 3 = 660
      child: ListView.builder(
        controller: controller,
        scrollDirection: Axis.vertical,
        itemCount: 3,
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
    );
  }
}

