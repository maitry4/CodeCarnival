import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecarnival/pages/student_home.dart';
import 'package:codecarnival/pages/teacher_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUseremail = FirebaseAuth.instance.currentUser!.email;
  String Role = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRole();
    print(Role);
  }

  void getRole() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUseremail)
        .get();
    setState(() {
      Role = (snap.data()! as dynamic)['Role'];
    });
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    if(Role == 'Student') {
              return const StudentHomePage();
            }
        else {
              return const TeacherHomePage();
        }

  }
}
