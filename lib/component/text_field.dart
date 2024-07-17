import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String? hintText;
  final String? errorText;
  final bool autofocus;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final TextEditingController controller;

  const CustomTextFormField({
    Key? key,
    this.hintText,
    this.errorText,
    this.autofocus = false,
    this.obscureText = false,
    required this.onChanged,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseDecoration = InputDecoration(
      contentPadding: EdgeInsets.all(20),
      hintText: hintText,
      errorText: errorText,
      hintStyle: TextStyle(
        color: Colors.black,
        fontSize: 14.0,
      ),
      fillColor: Colors.white,
      filled: true,
    );

    return TextFormField(
      controller: controller,
      cursorColor: Colors.black,
      autofocus: autofocus,
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: baseDecoration.copyWith(
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.0),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2.0),
        ),
      ),
    );
  }
}
