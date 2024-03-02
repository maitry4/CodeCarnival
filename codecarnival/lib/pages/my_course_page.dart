import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecarnival/components/tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyCoursePage extends StatefulWidget {
  const MyCoursePage({super.key});

  @override
  State<MyCoursePage> createState() => _MyCoursePageState();
}

class _MyCoursePageState extends State<MyCoursePage> {
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
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("Courses")
                  // .where('TeacherEmail', isEqualTo: username)
                  .orderBy("Time", descending: true)
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
                    child: Text('You Haven\'t Created Any Classes Yet.'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.only(right: 23),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(  
                  crossAxisCount: 1,  
                  crossAxisSpacing: 4.0,  
                  mainAxisSpacing: 4.0  
              ), 
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
                      type: role,
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
