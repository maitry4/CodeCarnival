import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecarnival/components/course_ui.dart';
import 'package:codecarnival/components/drawer.dart';
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

  // final List _pages = [
  //   const AddCoursePage(),
  //   const MyCoursePage(),
  // ];
  // int currentIndex = 0;
  // void goToPage(index) {
  //   setState(() {
  //     currentIndex = index;
  //   });
  // Navigator.push(
  //   context,
  //   MaterialPageRoute(
  //     builder: (context) => _pages[index],
  //   ),
  // ).then((_) {
  //   // Call the callback when navigation finishes
  //   getData();
  // });
  // }

  void getData() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('Users')
        .doc(username)
        .get();
    final value = await (snap.data()! as dynamic);
    setState(() {
      values = value;
    });
    print(
      values != null ? values!['LecutureCount'].toString() : 'Loading...',
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  int LectureCount = 0;
  void getLectureCount() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('Users')
        .doc(username)
        .get();
    setState(() {
      LectureCount = (snap.data()! as dynamic)["LectureCount"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(type:'teacher'),
      appBar: AppBar(),
      body: Column(
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
              ]),
              //  MyListTile(icon:Icons.book, text:'MY COURSES',),
            ],
          ),

          Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("Courses")
                      .orderBy("Time", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text('No Classes available.'),
                      );
                    }
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        // get message
                        final course = snapshot.data!.docs[index];
                        return CourseUi(
                          CourseName: course['CourseName'],
                          TeacherEmail: course['TeacherEmail'],
                          Date: course['Time'],
                          ID: course.id,
                          LectureCount: LectureCount,
                          type:'teacher',
                        );
                      },
                    );
                  })),
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
