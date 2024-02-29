import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecarnival/components/my_button.dart';
import 'package:codecarnival/pages/add_course_page.dart';
import 'package:codecarnival/pages/home_page.dart';
import 'package:codecarnival/pages/login_page.dart';
import 'package:codecarnival/pages/student_home.dart';
import 'package:codecarnival/pages/my_course_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  Color text_color = Colors.black;
  final username = FirebaseAuth.instance.currentUser != null
      ? FirebaseAuth.instance.currentUser!.email
      : 'something';
  Map? values;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  final List _pages = [
    const AddCoursePage(),
    const MyCoursePage(),
  ];
  int currentIndex = 0;
  void goToPage(index) {
    setState(() {
      currentIndex = index;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _pages[index],
      ),
    ).then((_) {
      // Call the callback when navigation finishes
      getData();
    });
  }

  void getData() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('Users')
        .doc(username)
        .get();
         final value = await (snap.data()! as dynamic);
        setState(() {
          values = value;
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFF000000),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
        child: GNav(
            backgroundColor: Colors.white,
            gap: 8,
            // color:  const Color(0xFF76DEAD),
            activeColor: Colors.red,
            // tabBackgroundColor: const Color(0xFF76DEAD),
            padding: const EdgeInsets.all(8),
            onTabChange: (index) => goToPage(index),
            tabs: const [
              GButton(
                icon: Icons.add,
                text: "Add Course",
              ),
              GButton(
                icon: Icons.remove_red_eye_sharp,
                text: "My Courses",
              ),
            ]),
      ),
      appBar: AppBar(actions: [
        IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout))
      ]),
      body: ListView(
        children: [
          // user details
          Row(
            // profile
            children: [
              IconButton(
                icon: Icon(Icons.person),
                onPressed: () {},
                color: text_color,
              ),
              // name & description
              Column(children: [
                Text(
                  values != null ? values!['username'] : 'Loading...',
                  style: TextStyle(color: text_color),
                ),
                Text(
                  values != null ? values!['bio'] : 'Loading...',
                  style: TextStyle(color: text_color),
                ),
              ]),
            ],
          ),
          Row(children: [
            Text(
              "Analytics",
              style: TextStyle(color: text_color),
            ),
          ]),
          Row(children: [
            Container(
                child: Column(
              children: [
                Text(
                  "Total Courses",
                  style: TextStyle(color: text_color),
                ),
                Text(
                  values != null
                      ? values!['CourseCount'].toString()
                      : 'Loading...',
                  style: TextStyle(color: text_color),
                ),
              ],
            )),
            SizedBox(
              width: 10,
            ),
            Container(
                child: Column(
              children: [
                Text(
                  "Total Lectures",
                  style: TextStyle(color: text_color),
                ),
                Text(
                  "0",
                  style: TextStyle(color: text_color),
                ),
              ],
            )),
          ]),
          Row(children: [
            Text(
              "Latest Lecture Notes",
              style: TextStyle(color: text_color),
            ),
          ]),
          Row(children: [
            Container(
              child: Column(
                children: [
                  Row(
                    children: [
                      // detail (title, time)
                      Text(
                        "Title",
                        style: TextStyle(color: text_color),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Text(
                        "time",
                        style: TextStyle(color: text_color),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // likes, students enrolled, doubts
                      Text(
                        "likes",
                        style: TextStyle(color: text_color),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "students",
                        style: TextStyle(color: text_color),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "doubts",
                        style: TextStyle(color: text_color),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ]),
          // ElevatedButton(
          //     child: Text("Pick File"),
          //     onPressed: ()async{
          //       print("before");
          //       FilePickerResult? result = await FilePicker.platform.pickFiles();
          //       print("Hiii");
          //       if (result != null) {
          //         print("done");
          //         File file = File(result.files.single.path!);
          //       } else {
          //         print("not done");
          //         // User canceled the picker
          //       }
          //     },
          //   ),
        ],
      ),
    );
  }
}
