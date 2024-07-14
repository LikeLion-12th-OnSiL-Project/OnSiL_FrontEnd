import 'package:flutter/material.dart';

class Walk extends StatefulWidget {
  const Walk({super.key});

  @override
  State<Walk> createState() => _WalkState();
}

class _WalkState extends State<Walk> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Walk'),
      ),
    );
  }
}
