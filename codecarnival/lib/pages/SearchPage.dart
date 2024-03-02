import 'package:codecarnival/components/drawer.dart';
import 'package:codecarnival/components/tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchPage extends StatefulWidget {
  String type;
   SearchPage({Key? key, required this.type}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<String> _courseNames = [];
  List<String> _foundCourses = [];
  // String type = "";
  final username = FirebaseAuth.instance.currentUser != null
      ? FirebaseAuth.instance.currentUser!.email
      : 'something';

  @override
  void initState() {
    super.initState();
    print("here");
    fetchCourseNames();
  }

  Future<void> fetchCourseNames() async {
    final coursesRef = FirebaseFirestore.instance.collection('Courses');
    final querySnapshot = await coursesRef.get();
    final courseNames = querySnapshot.docs.map((doc) => doc['CourseName'] as String).toList();

    // final userRef = FirebaseFirestore.instance.collection("Users").doc(username);
    // final querySnapshot2 = await userRef.get();
    // final x = querySnapshot2.data()!['Role'];
    setState(() {
      // type = x;
      _courseNames = courseNames;
      _foundCourses = courseNames;
    });
  }

  void _runFilter(String enteredKeyword) {
    List<String> results = [];
    if (enteredKeyword.isEmpty) {
      results = _courseNames;
    } else {
      results = _courseNames
          .where((course) => course.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _foundCourses = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: MyDrawer(type: type),
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) => _runFilter(value),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: "Search your Classes",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade600), //0₁
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade600)),
                  ),
                ),
              ),
              const SizedBox(
                height: 73,
              ),
              SizedBox(
                height: 500,
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection("Courses").snapshots(),
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
                          child: Text('No Courses available.'),
                        );
                      }
                
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final course = snapshot.data!.docs[index];
                          if (_foundCourses.contains(course['CourseName'])) {
                            // print("*********");
                            return CoffeeTile(
                                  CourseName: course['CourseName'],
                                  TeacherEmail: course['TeacherEmail'],
                                  Date: course['Time'],
                                  ID: course.id,
                                  LectureCount: 0,
                                  type: widget.type,
                                );
                            
                            
                          } else {
                            return SizedBox.shrink();
                          }
                        },
                      );
                    },
                  ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}
