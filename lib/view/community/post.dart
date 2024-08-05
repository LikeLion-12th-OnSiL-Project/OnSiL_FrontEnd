import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WritePostPage extends StatefulWidget {
  const WritePostPage({super.key});

  @override
  _WritePostPageState createState() => _WritePostPageState();
}

class _WritePostPageState extends State<WritePostPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _selectedCategory;
  final Map<String, String> _categories = {
    '산책': 'SAN',
    '질병': 'JIL',
    '친목': 'CHIN',
  }; // 사용자에게 보이는 카테고리 이름과 실제 값 매핑
  String? _imageId; // 업로드된 이미지 ID

  @override
  void initState() {
    super.initState();
    _retrieveLostData();
  }

  Future<void> _pickImage() async {
    try {
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

  Future<String?> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // 'token'은 저장된 토큰의 키입니다
  }

  Future<void> _uploadImage() async {
    if (_image == null) {
      _showErrorDialog(context, '이미지를 선택해 주세요.');
      return;
    }

    final String? token = await _getToken();
    if (token == null) {
      _showErrorDialog(context, '인증 토큰이 없습니다. 다시 로그인해 주세요.');
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://13.125.226.133/upload'), // 실제 서버 URL
      );

      request.headers['Authorization'] = 'Bearer $token';

      String fileName = path.basename(_image!.path);
      String? mimeType = lookupMimeType(_image!.path);
      if (mimeType == null) {
        _showErrorDialog(context, '파일의 MIME 타입을 확인할 수 없습니다.');
        return;
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // 서버에서 파일을 받는 필드 이름 (확인 필요)
          _image!.path,
          contentType: MediaType.parse(mimeType),
          filename: fileName,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        // 응답 본문을 JSON으로 파싱하지 않고 그대로 사용
        print('이미지 업로드 응답 본문: $responseBody');
        setState(() {
          _imageId = responseBody; // 서버가 반환하는 ID를 직접 사용
        });
        _showInfoDialog(context, '이미지가 성공적으로 업로드되었습니다.');
      } else {
        print('이미지 업로드 실패: ${response.statusCode}');
        final responseBody = await response.stream.bytesToString();
        print('응답 본문: $responseBody');
        _showErrorDialog(context, '이미지 업로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('이미지 업로드 중 오류 발생: $e');
      _showErrorDialog(context, '이미지 업로드 중 오류 발생: $e');
    }
  }

  Future<void> _uploadPost() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty || _selectedCategory == null || _imageId == null) {
      _showErrorDialog(context, '모든 필드와 이미지를 입력해주세요.');
      return;
    }

    final String? token = await _getToken();
    if (token == null) {
      _showErrorDialog(context, '인증 토큰이 없습니다. 다시 로그인해 주세요.');
      return;
    }

    try {
      var response = await http.post(
        Uri.parse('http://13.125.226.133/onsil/board/write'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': _titleController.text,
          'content': _contentController.text,
          'category': _selectedCategory,
          'image': _imageId,
        }),
      );

      if (response.statusCode == 200) {
        print('포스트 업로드 성공');
        _showInfoDialog(context, '포스트가 성공적으로 업로드되었습니다.');
      } else {
        print('포스트 업로드 실패: ${response.statusCode}');
        print('응답 본문: ${response.body}');
        _showErrorDialog(context, '포스트 업로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('업로드 중 오류 발생: $e');
      _showErrorDialog(context, '업로드 중 오류 발생: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext buildContext) {
        return AlertDialog(
          title: Text('오류'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(buildContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showInfoDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext buildContext) {
        return AlertDialog(
          title: Text('정보'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(buildContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '커뮤니티 글 쓰기',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_imageId == null) {
                _uploadImage(); // 이미지가 업로드되지 않은 경우 업로드 버튼 클릭
              } else {
                _uploadPost(); // 이미지가 업로드된 후 게시글 업로드
              }
            },
            child: Container(
              width: 100,
              height: 100,
              child: Image.asset('assets/img/finish2.png'),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: '제목을 입력하세요.',
                  hintStyle: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                  filled: true,
                  fillColor: Colors.white,
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
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: '온실 주민과 이야기를 나눠보세요.',
                  hintStyle: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                  filled: true,
                  fillColor: Colors.white,
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
                      ? Center(child: Text('사진을 선택하세요.', style: TextStyle(color: Colors.grey)))
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
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _uploadImage,
                child: Text('이미지 업로드'),
              ),
              SizedBox(height: 10),
              DropdownButton<String>(
                hint: Text('카테고리를 선택하세요'),
                value: _selectedCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                items: _categories.entries.map<DropdownMenuItem<String>>((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.value, // 실제 값으로 설정
                    child: Text(entry.key), // 사용자에게 보이는 텍스트
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
