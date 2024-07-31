import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lion12/view/home.dart';
import 'package:lion12/view/walk.dart';
import 'package:lion12/view/community.dart';
import 'package:lion12/view/diet.dart';
import 'package:lion12/view/mypage.dart';
import 'package:lion12/view/topbar.dart';
import 'package:lion12/provider/nick.dart';

class RootTab extends StatefulWidget {
  static String get routeName => 'home';

  const RootTab({Key? key}) : super(key: key);

  @override
  State<RootTab> createState() => _RootTabState();
}

class _RootTabState extends State<RootTab> with SingleTickerProviderStateMixin {
  late TabController controller;
  int index = 0;
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 5, vsync: this);
    controller.addListener(tabListener);
  }

  @override
  void dispose() {
    controller.removeListener(tabListener);
    controller.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void tabListener() {
    setState(() {
      index = controller.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 하얀색으로 설정
      appBar: const Topbar(),
      body: TabBarView(
        controller: controller,
        children: const [
          Home(),
          MapScreen(),
          Diet(),
          PostPage(),
          Mypage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, // BottomNavigationBar 배경색 설정
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.black,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          controller.animateTo(index);
        },
        currentIndex: index,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(index == 0 ? 'assets/img/home2.png' : 'assets/img/home.png'),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(index == 1 ? 'assets/img/sss2.png' : 'assets/img/sss.png'),
            label: '산책',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(index == 2 ? 'assets/img/food2.png' : 'assets/img/food.png'),
            label: '식단',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(index == 3 ? 'assets/img/commu2.png' : 'assets/img/commu.png'),
            label: '커뮤니티',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(index == 4 ? 'assets/img/my2.png' : 'assets/img/my.png'),
            label: '마이',
          ),
        ],
      ),
    );
  }
}

