// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecarnival/components/course_lectures_ui.dart';
import 'package:codecarnival/components/my_button.dart';
import 'package:codecarnival/pages/add_lecture_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class CoffeeTile extends StatefulWidget {
  final String CourseName;
  final String TeacherEmail;
  final String Date;
  final String ID;
  final String type;
  int LectureCount;
CoffeeTile({
    super.key,
    required this.CourseName,
    required this.TeacherEmail,
    required this.Date,
    required this.ID,
    required this.LectureCount,
    required this.type,
  });

  @override
  State<CoffeeTile> createState() => _CoffeeTileState();
}

class _CoffeeTileState extends State<CoffeeTile> {
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
        Widget build (BuildContext context) {
        return Padding(
        padding: const EdgeInsets.only (left: 30.0, bottom: 18),
        child: Container(
        padding: EdgeInsets.all(10),
        width: 200,
        decoration: BoxDecoration (
        borderRadius: BorderRadius.circular(12),
        color: Color.fromARGB(58, 229, 181, 58),
        ), 
            child: Column( 
               crossAxisAlignment: CrossAxisAlignment.start,
           children: [
           
      // coffee image
        ClipRRect(
           borderRadius: BorderRadius.circular (12),
          // Image.asset('lib/images/latte.png'),
      ), // ClipRRect
    // coffee name
           // coffee name
         Padding(
           padding: const EdgeInsets.symmetric(vertical:10.0),
           child: Column(

               crossAxisAlignment: CrossAxisAlignment.start,
             children: [
                Text(
                     widget.CourseName,
                 style: TextStyle(fontSize: 20),
                   ), 
               Text(
                 widget.TeacherEmail,
                  style: TextStyle(color: Colors.grey [700]),
                   ), 
             ],
                ),
         ), 

         //add button
         // price
              // Padding(
              //       padding: const EdgeInsets.all(8.0),
              //            child: Row(
              //            mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //              children: [
              //              //Text('$4.00'),
              //                Container(
              //               padding: EdgeInsets.all(6),
              //                decoration: BoxDecoration(
              //                color: Color.fromARGB(255, 255, 228, 228),
              //                 borderRadius: BorderRadius.circular (10),
              //                   ),  
              //                         child: Icon (Icons.add),
              //              ), 
              //              ],
              //          ), 
              //        ) ,
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
           ],
), 
        )
);
}
}