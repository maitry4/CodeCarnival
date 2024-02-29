import 'package:flutter/material.dart';
class MyListTile extends StatelessWidget {
  final String text;
  final IconData icon;
  final void Function()? onTap;
  const MyListTile({super.key, required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }
}