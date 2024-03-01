import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: hintText,
               focusedBorder: OutlineInputBorder(
               borderSide: BorderSide (color: Color(0xfff8b30d)), //0₁
                ), 
               enabledBorder: OutlineInputBorder(
               borderSide: BorderSide (color: Color(0xfff8b30d))
               ),
               ),
      ),
    );
  }
}