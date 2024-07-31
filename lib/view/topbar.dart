import 'package:flutter/material.dart';
import 'package:lion12/const/colors.dart';

class Topbar extends StatelessWidget implements PreferredSizeWidget {
  const Topbar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        height: 40.0,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/img/Vector.png', // Vector 이미지 경로 설정
                  height: 30.0,
                  width: 30.0,
                ),
                Image.asset(
                  'assets/img/Union.png', // Union 이미지 경로 설정
                  height: 30.0,
                  width: 30.0,
                ),
              ],
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications_none, color: fontColor),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.0);
}