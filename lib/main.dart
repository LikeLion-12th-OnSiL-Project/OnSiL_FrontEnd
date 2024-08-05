import 'package:flutter/material.dart';
import 'package:lion12/provider/nick.dart';
import 'package:lion12/user/view/login_screen.dart';
import 'package:lion12/component/root.dart';
import 'package:lion12/view/walk/map.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NicknameProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
    );
  }
}