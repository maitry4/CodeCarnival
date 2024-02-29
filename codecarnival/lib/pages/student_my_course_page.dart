import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecarnival/components/course_ui.dart';
import 'package:codecarnival/components/my_button.dart';
import 'package:codecarnival/helper/helper_method.dart';
import 'package:codecarnival/pages/teacher_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class StudentMyCoursePage extends StatefulWidget {
  const StudentMyCoursePage({super.key});

  @override
  State<StudentMyCoursePage> createState() => _StudentMyCoursePageState();
}

class _StudentMyCoursePageState extends State<StudentMyCoursePage> {
  final username = FirebaseAuth.instance.currentUser != null
      ? FirebaseAuth.instance.currentUser!.email
      : 'something';
  
  String role = '';
  void getUserType() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('Users')
        .doc(username)
        .get();
    setState(() {
      role = (snap.data()! as dynamic)["Role"];
    });
    print(username);
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
  void initState() {
    // TODO: implement initState
    super.initState();
    getLectureCount();
    getUserType();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("Courses")
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
                    child: Text('You Haven\'t Enrolled In Any Classes Yet.'),
                  );
                }

                final myCourses = snapshot.data!.docs
                    .where((doc) => doc['Students'].contains(username))
                    .toList();

                print(myCourses); // This will print the filtered courses

                return ListView.builder(
                  itemCount: myCourses.length,
                  itemBuilder: (context, index) {
                    final course = myCourses[index];
                    print("username");
                    return CourseUi(
                      CourseName: course['CourseName'],
                      TeacherEmail: course['TeacherEmail'],
                      Date: course['Time'],
                      ID: course.id,
                      LectureCount: LectureCount,
                      type: 'student',
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
