import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:mime/mime.dart';

class WritePostPage extends StatefulWidget {
  const WritePostPage({super.key});

  @override
  _WritePostPageState createState() => _WritePostPageState();
}

class _WritePostPageState extends State<WritePostPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  @override
  void initState() {
    super.initState();
    _retrieveLostData();
  }

  Future<void> _pickImage() async {
    try {
      // 갤러리에서 이미지 선택
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
        });
      }
    } catch (e) {
      print("Image picker error: $e");
    }
  }

  Future<void> _retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image = response.file;
      });
    } else {
      print(response.exception!.code);
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://example.com/upload'), // 실제 서버 URL
      );

      String fileName = basename(_image!.path);
      String? mimeType = lookupMimeType(_image!.path);

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          _image!.path,
          contentType: MediaType.parse(mimeType!),
          filename: fileName,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        print('이미지 업로드 성공');
      } else {
        print('이미지 업로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('업로드 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('                          글쓰기'),
        actions: [
          GestureDetector(
            child: Image.asset(
                'assets/img/finish.png'
            ),
            onTap: _uploadImage,
          ),
        ],
      ),
      backgroundColor: Colors.white, // Scaffold 배경색을 하얀색으로 설정
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: '제목을 입력하세요.',
                  filled: true, // 배경색을 적용하기 위해 filled 속성 사용
                  fillColor: Colors.white, // TextField의 배경색을 하얀색으로 설정
                  border: OutlineInputBorder(), // 경계선을 추가하여 텍스트 필드를 더 뚜렷하게
                ),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  hintText: '온실 주민과 이야기를 나눠보세요.',
                  filled: true, // 배경색을 적용하기 위해 filled 속성 사용
                  fillColor: Colors.white, // TextField의 배경색을 하얀색으로 설정
                  border: OutlineInputBorder(), // 경계선을 추가하여 텍스트 필드를 더 뚜렷하게
                ),
                maxLines: 5,
              ),
              SizedBox(height: 10),
              _image == null
                  ? Text('선택된 이미지가 없습니다.')
                  : FutureBuilder<File>(
                future: Future<File>.value(File(_image!.path)),
                builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Text('이미지 로드 중 오류 발생: ${snapshot.error}');
                    }
                    return Image.file(snapshot.data!);
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
              SizedBox(height: 10), // 버튼과 이미지 사이의 여백 추가
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('이미지 선택'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
