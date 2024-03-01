import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecarnival/components/course_ui.dart';
import 'package:codecarnival/components/drawer.dart';
import 'package:codecarnival/components/tile.dart';
import 'package:codecarnival/pages/teacher_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          Padding(
              padding: const EdgeInsets.symmetric (vertical: 10.0, horizontal:13),
              child: Text(
              "Discover your class and join the journey today!",
              style: GoogleFonts.bebasNeue( fontSize:47, ),
             
              ),
            ), 
            SizedBox(height: 25,),
            // Search Bar
         Padding(
           padding: const EdgeInsets.symmetric(horizontal:25.0),
           child: TextField(
             decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: "Search your Classes",
               focusedBorder: OutlineInputBorder(
               borderSide: BorderSide (color: Colors.grey.shade600), //0₁
                ), 
               enabledBorder: OutlineInputBorder(
               borderSide: BorderSide (color: Colors.grey.shade600)
               ),
               ),
                ),
         ),
        SizedBox(height:25),
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