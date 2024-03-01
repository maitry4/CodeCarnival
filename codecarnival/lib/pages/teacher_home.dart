import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecarnival/components/course_ui.dart';
import 'package:codecarnival/components/drawer.dart';
import 'package:codecarnival/components/my_button.dart';
import 'package:codecarnival/components/tile.dart';
import 'package:codecarnival/pages/SearchPage.dart';
import 'package:codecarnival/pages/add_course_page.dart';
import 'package:codecarnival/pages/home_page.dart';
import 'package:codecarnival/pages/login_page.dart';
import 'package:codecarnival/pages/student_home.dart';
import 'package:codecarnival/pages/my_course_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      drawer: MyDrawer(type: 'teacher'),
      appBar: AppBar(),
      body: Column(
        children: [
          // user details
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 13),
            child: Text(
              "Discover your class and join the journey today!",
              style: GoogleFonts.bebasNeue(
                fontSize: 47,
              ),
            ),
          ),
          SizedBox(
            height: 25,
          ),

          MyButton(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchPage(),
                    ));
              },
              text: "Search"),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search your Classes",
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade600), //0₁
                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade600)),
              ),
              onSubmitted: (string) {},
            ),
          ),
          SizedBox(height: 25),
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
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        // get message
                        final course = snapshot.data!.docs[index];
                        return CoffeeTile(
                          CourseName: course['CourseName'],
                          TeacherEmail: course['TeacherEmail'],
                          Date: course['Time'],
                          ID: course.id,
                          LectureCount: LectureCount,
                          type: 'teacher',
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
