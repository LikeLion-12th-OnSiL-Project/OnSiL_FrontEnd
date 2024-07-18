import 'package:flutter/material.dart';
import 'package:lion12/user/view/login_screen.dart';
import 'package:lion12/view/root.dart';
import 'package:lion12/view/map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Map(),
    );
  }
}