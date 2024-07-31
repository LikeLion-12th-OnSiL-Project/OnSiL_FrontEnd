import 'package:flutter/material.dart';
import 'package:lion12/const/colors.dart';

class Topbar extends StatelessWidget implements PreferredSizeWidget {
  const Topbar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        height: 56.0, // Topbar의 전체 높이를 56으로 설정
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/img/Vector.png', // Vector 이미지 경로 설정
                  height: 40.0, // 높이를 40으로 설정
                  width: 40.0, // 너비를 40으로 설정
                ),
                //SizedBox(width: 4.0), // 이미지들 사이 간격을 더 가깝게 하기 위해 제거 또는 너비 축소
                Image.asset(
                  'assets/img/Union.png', // Union 이미지 경로 설정
                  height: 40.0, // 높이를 40으로 설정
                  width: 40.0, // 너비를 40으로 설정
                ),
              ],
            ),
            IconButton(
              onPressed: () {},
              icon: Container(
                width: 40.0, // 너비를 40으로 설정
                height: 40.0, // 높이를 40으로 설정
                child: Image.asset(
                  'assets/img/bell.png',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.0);
}
