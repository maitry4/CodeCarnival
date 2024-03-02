import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecarnival/components/my_button.dart';
import 'package:codecarnival/components/my_textfield.dart';
import 'package:codecarnival/helper/helper_method.dart';
import 'package:codecarnival/pages/teacher_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final username = FirebaseAuth.instance.currentUser != null ? FirebaseAuth.instance.currentUser!.email : 'something';
  final courseController = TextEditingController();
  void goHome() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TeacherHomePage(),
      ),
    );
  }
  void createCourse() async {
    if (courseController.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Class Name Can't Be Empty!"),
              duration: Duration(seconds: 2),
            ));
      return;
    }
    Timestamp date = Timestamp.now();

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection('Courses').add({
      'TeacherEmail':username,
      'Time':formatDate(date),
      'Students':[],
      'CourseName':courseController.text,
    });
    // clear the text field
    setState(() {
      courseController.clear();
    });
    
    DocumentSnapshot snap = await FirebaseFirestore.instance.collection('Users').doc(username).get();
    
    int courseCount= (snap.data()! as dynamic)['CourseCount'];
    courseCount = courseCount + 1;
    firestore.collection('Users').doc(username).update({
      'CourseCount':courseCount,
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Class Created"),
              duration: Duration(seconds: 2),
            ));
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: MyTextField(controller: courseController, hintText: "Enter Class Name", obscureText: false),
          ),
          const SizedBox(height: 10,),
          MyButton(onTap: createCourse, text: "Add a New Class",),
        ],
      ),
    );
  }
}