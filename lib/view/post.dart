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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('                 커뮤니티 글 쓰기',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 완료 버튼을 눌렀을 때의 로직
            },
            child: Container(
              width: 100, // 원하는 너비로 설정
              height: 100, // 원하는 높이로 설정
              child: Image.asset('assets/img/finish2.png'),
            ),
          )
        ],
      ),
       // Scaffold 배경색을 하얀색으로 설정
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: '제목을 입력하세요.',
                  hintStyle: TextStyle(
                    fontSize: 16.0, // hintText의 글꼴 크기
                    fontWeight: FontWeight.w500, // hintText의 글꼴 두께 (예: w600은 보통 두꺼운 글꼴)
                    color: Colors.grey, // hintText의 색상 (선택사항)
                  ),
                  filled: true, // 배경색을 적용하기 위해 filled 속성 사용
                  fillColor: Colors.white, // TextField의 배경색을 하얀색으로 설정
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  hintText: '온실 주민과 이야기를 나눠보세요.',
                  hintStyle: TextStyle(
                    fontSize: 16.0, // hintText의 글꼴 크기
                    fontWeight: FontWeight.w500, // hintText의 글꼴 두께 (예: w600은 보통 두꺼운 글꼴)
                    color: Colors.grey, // hintText의 색상 (선택사항)
                  ),
                  filled: true, // 배경색을 적용하기 위해 filled 속성 사용
                  fillColor: Colors.white, // TextField의 배경색을 하얀색으로 설정
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                ),
                maxLines: 5,
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.blue,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: _image == null
                      ? Center(child: Text('사진를 선택하세요.', style: TextStyle(color: Colors.grey)))
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.file(
                      File(_image!.path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10), // 버튼과 이미지 사이의 여백 추가
              GestureDetector(
                onTap: _pickImage,
                child: Image.asset('assets/img/photo3.png'),
              )

            ],
          ),
        ),
      ),
    );
  }
}
