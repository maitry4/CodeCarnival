import 'package:codecarnival/pages/teacher_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

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

    final username = FirebaseAuth.instance.currentUser != null ? FirebaseAuth.instance.currentUser!.email : 'something';
  final List _pages = [
    const StudentHomePage(),
  ];
   int currentIndex = 0;
  void goToPage(index) {
    setState(() {
      currentIndex = index;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => _pages[index],
      ),
    );
  }
  
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal:15.0, vertical:20.0),
        child: GNav(
          backgroundColor: Colors.white,
            gap: 8,
                // color:  const Color(0xFF76DEAD),
                // activeColor: Colors.white,
                // tabBackgroundColor: const Color(0xFF76DEAD),
                padding:const EdgeInsets.all(8),
                onTabChange: (index) => goToPage(index),
                tabs:const [
                  GButton(
                    icon: Icons.home,
                    text:"Home",
                  ),

                ]
          ),
      ),
      appBar:AppBar(
        actions:[IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout))
        ]),
      backgroundColor: Colors.black,
    );
  }
}