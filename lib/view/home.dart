import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200.0,
              color: Colors.blue,
              child: Center(
                child: Text(
                  '고정되지 않는 상단 컨텐츠',
                  style: TextStyle(color: Colors.white, fontSize: 24.0),
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 50,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('아이템 $index'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
