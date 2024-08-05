import 'package:flutter/material.dart';
import 'package:lion12/const/colors.dart';

class Topbar extends StatelessWidget implements PreferredSizeWidget {
  const Topbar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        height: 56.0, // Set the total height of the top bar to 56
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey, // Set the border color to gray
              width: 1.0, // Set the border width
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/img/Vector.png', // Set the path to the Vector image
                  height: 40.0, // Set the height to 40
                  width: 40.0, // Set the width to 40
                ),
                Image.asset(
                  'assets/img/Union.png', // Set the path to the Union image
                  height: 40.0, // Set the height to 40
                  width: 40.0, // Set the width to 40
                ),
              ],
            ),
            IconButton(
              onPressed: () {},
              icon: Container(
                width: 40.0, // Set the width to 40
                height: 40.0, // Set the height to 40
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