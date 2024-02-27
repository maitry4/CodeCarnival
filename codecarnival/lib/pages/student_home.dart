import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        actions:[IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout))
        ]),
      backgroundColor: Colors.black,
    );
  }
}