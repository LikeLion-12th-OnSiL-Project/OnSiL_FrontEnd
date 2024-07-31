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

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _showNicknameDialog();
    // });
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

  // void _showNicknameDialog() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('닉네임 입력'),
  //         content: TextField(
  //           controller: _nicknameController,
  //           decoration: InputDecoration(hintText: '닉네임을 입력하세요'),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               if (_nicknameController.text.isNotEmpty) {
  //                 Provider.of<NicknameProvider>(context, listen: false)
  //                     .setNickname(_nicknameController.text);
  //                 Navigator.of(context).pop();
  //                 _showNicknameConfirmation(_nicknameController.text);
  //               } else {
  //                 _showErrorDialog();
  //               }
  //             },
  //             child: Text('확인'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  //
  // void _showNicknameConfirmation(String nickname) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('닉네임 설정 완료'),
  //         content: Text('설정된 닉네임: $nickname'),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text('확인'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  //
  // void _showErrorDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('오류'),
  //         content: Text('닉네임을 입력해주세요.'),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text('확인'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
