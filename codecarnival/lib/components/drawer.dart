import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecarnival/components/list_tile.dart';
import 'package:codecarnival/pages/ChatBot.dart';
import 'package:codecarnival/pages/add_course_page.dart';
import 'package:codecarnival/pages/my_course_page.dart';
import 'package:codecarnival/pages/student_my_course_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatefulWidget {
  final String type;
  const MyDrawer({super.key, required this.type});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
      children: [
        const DrawerHeader(child: Icon(Icons.person, size: 64)),
        Text(
          values != null ? values!['username'] : 'Loading...',
          style: TextStyle(color: text_color),
        ),
        if(widget.type == 'teacher')
        MyListTile(
          icon: Icons.book,
          text: "\nMY CLASSES \n(add lectures here)",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyCoursePage(),
              ),
            );
          },
        ),
        if(widget.type == 'student')
        MyListTile(
          icon: Icons.book,
          text: 'MY CLASSES',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StudentMyCoursePage(),
              ),
            );
          },
        ),
        if(widget.type == 'teacher')
        MyListTile(
          icon: Icons.add_box,
          text: "ADD CLASS",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddCoursePage(),
              )
            );
          },
        ),
        MyListTile(
          icon: Icons.question_answer,
          text: 'Ask Doubt',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Chatbot(),
              ),
            );
          },
        ),
        const SizedBox(
          height: 350,
        ),
        IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout))
      ],
    ));
  }
}
