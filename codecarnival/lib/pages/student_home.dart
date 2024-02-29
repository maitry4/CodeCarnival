import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecarnival/components/course_ui.dart';
import 'package:codecarnival/components/drawer.dart';
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
  Color text_color = Colors.black;
  final username = FirebaseAuth.instance.currentUser != null
      ? FirebaseAuth.instance.currentUser!.email
      : 'something';
  Map? values;
  void signUserOut() {
    FirebaseAuth.instance.signOut();
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
      drawer: MyDrawer(type:'student'),
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
                          type:'student',
                        );
                      },
                    );
                  })),
        ],
      ),
    );
  }
}