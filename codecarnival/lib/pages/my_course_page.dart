import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecarnival/components/course_ui.dart';
import 'package:codecarnival/components/my_button.dart';
import 'package:codecarnival/helper/helper_method.dart';
import 'package:codecarnival/pages/teacher_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyCoursePage extends StatefulWidget {
  const MyCoursePage({super.key});

  @override
  State<MyCoursePage> createState() => _ViewCoursePageState();
}

class _ViewCoursePageState extends State<MyCoursePage> {
  final username = FirebaseAuth.instance.currentUser != null ? FirebaseAuth.instance.currentUser!.email : 'something';

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(),
      body:   Column(
        children: [
          Expanded(
            child: StreamBuilder(
                      stream:FirebaseFirestore.instance
                      .collection("Courses")
                      .where('TeacherEmail', isEqualTo: username)
                      .orderBy(
                        "Time",
                        descending: true)
                      .snapshots(),
                      builder: (context, snapshot) {
                        if(snapshot.hasData) {
                          return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                            // get message
                            final course = snapshot.data!.docs[index];
                            return CourseUi(
                              CourseName:course['CourseName'],
                              TeacherEmail:course['TeacherEmail'],
                              Date:course['Time'],
                              ID:course.id,
                              LectureCount:course['LectureCount'],
                            );
                              
                          },
                         );
                        }
                        else if(snapshot.hasError) {
                          return Center(child: Text('Error${snapshot.error}'));
                        }
                        return const Center(child: CircularProgressIndicator(),);
                      },
                      ),
          ),
        ],
      ),
              
            
    );
  }
}