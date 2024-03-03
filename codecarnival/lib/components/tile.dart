// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecarnival/components/course_lectures_ui.dart';
import 'package:codecarnival/components/my_button.dart';
import 'package:codecarnival/pages/add_lecture_page.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ClassUi extends StatefulWidget {
  final String CourseName;
  final String TeacherEmail;
  final String Date;
  final String ID;
  final String type;
  int LectureCount;
  ClassUi({
    super.key,
    required this.CourseName,
    required this.TeacherEmail,
    required this.Date,
    required this.ID,
    required this.LectureCount,
    required this.type,
  });

  @override
  State<ClassUi> createState() => _ClassUiState();
}

class _ClassUiState extends State<ClassUi> {
  final username = FirebaseAuth.instance.currentUser != null
      ? FirebaseAuth.instance.currentUser!.email
      : 'something';
  String? url;
  String reference = "";
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  ChatUser myself = ChatUser(id: "1", firstName: "Shivangi");
  ChatUser bot = ChatUser(id: "2", firstName: "bot");
  List<ChatMessage> allMessages = [];
  List<ChatUser> typing = [];
  final ourUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyBYE0mEekGvkn_Q9m3Tm6RgJ4yRU8JqtfE";
  final header = {'Content-Type': 'application/json'};

  Future<String> fetchData(String message) async {
    try {
      var data = {
        "contents": [
          {
            "parts": [
              {"text": message}
            ]
          }
        ]
      };
      final response = await http.post(Uri.parse(ourUrl),
          headers: header, body: jsonEncode(data));
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result["candidates"][0]["content"]['parts'][0]["text"];
      } else {
        print("Failed to fetch data. Error code: ${response.statusCode}");
        return ""; // or throw an error if necessary
      }
    } catch (e) {
      print("Exception occurred: $e");
      return ""; // or throw an error if necessary
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // To delete an existing course
  void deleteCourse() {
    // Show circular progress indicator
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog dismissal
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Delete Course"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(), // Circular progress indicator
            SizedBox(height: 20.0),
            Text("Deleting course..."),
          ],
        ),
        actions: const [
          // HIDE BUTTONS WHILE DELETING
          SizedBox.shrink(),
          SizedBox.shrink(),
        ],
      ),
    );

    // Perform deletion asynchronously
    Future.delayed(Duration(seconds: 1), () async {
      // Delete the comments
      final lectureDoc = await FirebaseFirestore.instance
          .collection("Courses")
          .doc(widget.ID)
          .collection("Lectures")
          .get();

      for (var doc in lectureDoc.docs) {
        // Get the FileURL from the lecture document
        final String fileUrl = doc.get("FileURL") ?? "";

        // If FileURL exists, delete the file from storage
        if (fileUrl.isNotEmpty) {
          final storageRef = FirebaseStorage.instance.refFromURL(fileUrl);
          await storageRef.delete();
        }

        // Delete the lecture document
        await doc.reference.delete();
      }

      // Delete the course document
      await FirebaseFirestore.instance
          .collection("Courses")
          .doc(widget.ID)
          .delete();

      // Dismiss the dialog
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Class Deleted Successfully"),
      duration: Duration(seconds: 2),
    ));
  }

  void goToLectures() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseLecutreUi(courseID: widget.ID),
      ),
    );
  }

  // Check if user is enrolled and update buttons accordingly
  Future<bool> isEnrolled() async {
    DocumentSnapshot courseSnapshot = await FirebaseFirestore.instance
        .collection("Courses")
        .doc(widget.ID)
        .get();
    List<dynamic> students = courseSnapshot['Students'] ?? [];
    return students.contains(username);
  }

  void enrollInClass() async {
    DocumentSnapshot courseSnapshot = await FirebaseFirestore.instance
        .collection("Courses")
        .doc(widget.ID)
        .get();
    List<dynamic> students = courseSnapshot['Students'] ?? [];

    // Check if enrolled, otherwise add to course and user
    if (!students.contains(username)) {
      students.add(username);
      await FirebaseFirestore.instance
          .collection("Courses")
          .doc(widget.ID)
          .update({'Students': students});
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(username)
          .update({
        'Courses': FieldValue.arrayUnion([widget.ID])
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("You are enrolled in this class!"),
        duration: Duration(seconds: 2),
      ));
    } else {
      // Remove from course and user if already enrolled
      students.remove(username);
      await FirebaseFirestore.instance
          .collection("Courses")
          .doc(widget.ID)
          .update({'Students': students});
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(username)
          .update({
        'Courses': FieldValue.arrayRemove([widget.ID]),
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("You are unenrolled from this class."),
        duration: Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 30.0, bottom: 18),
        child: Container(
          padding: EdgeInsets.all(10),
          width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[400],
            image: DecorationImage(
              image: AssetImage("lib/images/background_img.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // coffee image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                // Image.asset('lib/images/latte.png'),
              ), // ClipRRect

              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.CourseName,
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      widget.TeacherEmail,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),

              MyButton(onTap: goToLectures, text: "See Lectures"),
              SizedBox(height: 20),
              if (widget.type == 'student')
                FutureBuilder<bool>(
                  future: isEnrolled(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!) {
                        // User is enrolled, show unenroll button
                        return Column(
                          children: [
                            MyButton(onTap: enrollInClass, text: "Unenroll"),
                            SizedBox(height: 20,),
                            MyButton(
                                onTap: () {
                              
                                      showDialog(context: context, builder: (context) {
      
        return AlertDialog(title: FutureBuilder<String>(
                              future: fetchData(
                                  'Provide a simple question related to ${widget.CourseName}'), // Call fetchData here
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(child: Container(child: const CircularProgressIndicator())); // Return loading indicator while fetching data
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  // If data is fetched successfully, display it
                                  return Text(snapshot.data ??
                                      ''); // Display fetched data
                                }
                              },
                            ));
      
    });
                                      // print(res);
                                },
                                text: "Drill"),
                          ],
                        );
                      } else {
                        // User is not enrolled, show enroll button
                        return MyButton(
                            onTap: enrollInClass, text: "Enroll In Class");
                      }
                    } else {
                      // Loading state
                      return CircularProgressIndicator();
                    }
                  },
                ),
              if (widget.TeacherEmail == username)
                MyButton(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddLecturePage(
                                ID: widget.ID,
                                LectureCount: widget.LectureCount),
                          ));
                    },
                    text: "Create Lectures"),
              SizedBox(
                height: 25,
              ),
              if (widget.TeacherEmail == username)
                // MyButton(onTap: deleteCourse, text: "Delete"),
                IconButton(
                    onPressed: deleteCourse,
                    icon: Icon(
                      Icons.delete,
                      color: Color.fromARGB(255, 248, 12, 12),
                      size: 50,
                    )),

              // Text("Delete")
            ],
          ),
        ));
  }
}
