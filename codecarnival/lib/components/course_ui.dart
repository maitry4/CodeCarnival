import 'dart:io';
import 'package:codecarnival/components/course_lectures_ui.dart';
import 'package:codecarnival/pages/add_lecture_page.dart';
import 'package:codecarnival/pages/teacher_home.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecarnival/components/my_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class CourseUi extends StatefulWidget {
  final String CourseName;
  final String TeacherEmail;
  final String Date;
  final String ID;
  final String type;
  int LectureCount;
  CourseUi({
    super.key,
    required this.CourseName,
    required this.TeacherEmail,
    required this.Date,
    required this.ID,
    required this.LectureCount,
    required this.type,
  });

  @override
  State<CourseUi> createState() => _CourseUiState();
}

class _CourseUiState extends State<CourseUi> {
  final username = FirebaseAuth.instance.currentUser != null
      ? FirebaseAuth.instance.currentUser!.email
      : 'something';
  String? url;
  String reference = "";
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
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
        children: [
          CircularProgressIndicator(), // Circular progress indicator
          SizedBox(height: 20.0),
          Text("Deleting course..."),
        ],
      ),
      actions: [
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

    // Remove the course from all enrolled users' "Courses" array
    // await FirebaseFirestore.instance.runTransaction((transaction) async {
  // Delete the course document
  // await transaction.delete(FirebaseFirestore.instance.collection("Courses").doc(widget.ID));

  // Remove the course from all enrolled users' "Courses" array
  // final username = FirebaseAuth.instance.currentUser != null
  //     ? FirebaseAuth.instance.currentUser!.email
  //     : 'something';
  // final userDoc = FirebaseFirestore.instance.collection("Users").doc(username);
  // final userSnap = await transaction.get(userDoc);
  // if (userSnap.exists) {
  //   List<dynamic> courses = userSnap.get("Courses") ?? [];
  //   if (courses.contains(widget.ID)) {
  //     courses.remove(widget.ID);
  //     await transaction.update(userDoc, {"Courses": courses});
  //   }
  // }
    // });

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
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(widget.CourseName),
                Text(widget.TeacherEmail),
                Text(widget.Date),
              ],
            ),
            if (widget.TeacherEmail == username)
              GestureDetector(
                  child: Icon(
                    Icons.delete,
                  ),
                  onTap: deleteCourse),
          ],
        ),
        MyButton(onTap: goToLectures, text: "See Lectures"),
        SizedBox(height: 20),
        if(widget.type == 'student')
        FutureBuilder<bool>(
          future: isEnrolled(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!) {
                // User is enrolled, show unenroll button
                return MyButton(onTap: enrollInClass, text: "Unenroll");
              } else {
                // User is not enrolled, show enroll button
                return MyButton(onTap: enrollInClass, text: "Enroll In Class");
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
                          ID: widget.ID, LectureCount: widget.LectureCount),
                    ));
              },
              text: "Create Lectures")
      ]),
    );
  }
}
