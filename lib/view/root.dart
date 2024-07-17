import 'package:flutter/material.dart';
import 'package:lion12/view/mypage.dart';
import 'package:lion12/view/walk.dart';
import 'package:lion12/view/community.dart';
import 'package:lion12/view/diet.dart';
import 'package:lion12/view/home.dart';
import 'package:lion12/view/topbar.dart';

class RootTab extends StatefulWidget {
  static String get routeName => 'home';

  const RootTab({Key? key}) : super(key: key);

  @override
  State<RootTab> createState() => _RootTabState();
}

class _RootTabState extends State<RootTab> with SingleTickerProviderStateMixin {
  late TabController controller;
  int index = 0;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 5, vsync: this);
    controller.addListener(tabListener);
  }

  @override
  void dispose() {
    controller.removeListener(tabListener);
    controller.dispose(); // 컨트롤러를 제대로 dispose
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
      appBar: const Topbar(),
      body: TabBarView(
        controller: controller,
        children: const [
          Home(),
          Walk(),
          Diet(),
          Community(),
          Mypage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.black,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          controller.animateTo(index);
        },
        currentIndex: index,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assist_walker),
            label: '산책',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood_outlined),
            label: '식단',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: '커뮤니티',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            label: '마이',
          ),
        ],
      ),
    );
  }
}
