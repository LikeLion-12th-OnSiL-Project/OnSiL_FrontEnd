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
            Text('로고', style: TextStyle(color: fontColor, fontSize: 20)),
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
