import 'package:codecarnival/firebase_options.dart';
import 'package:codecarnival/pages/auth_page.dart';
import 'package:codecarnival/pages/home_page.dart';
import 'package:codecarnival/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  void something(){}
  @override
  Widget build(BuildContext context) {
      return MaterialApp(
      // darkTheme: darkTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
    );
  }
}