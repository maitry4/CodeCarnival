import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecarnival/components/tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('You Haven\'t Enrolled In Any Classes Yet.'),
                  );
                }

                final myCourses = snapshot.data!.docs
                    .where((doc) => doc['Students'].contains(username))
                    .toList();

                print(myCourses); // This will print the filtered courses

                return GridView.builder(
                  padding: const EdgeInsets.only(right: 23),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(  
                  crossAxisCount: 1,  
                  crossAxisSpacing: 4.0,  
                  mainAxisSpacing: 4.0  
              ),  
                  itemCount: myCourses.length,
                  itemBuilder: (context, index) {
                    final course = myCourses[index];
                    print("username");
                    return ClassUi(
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
