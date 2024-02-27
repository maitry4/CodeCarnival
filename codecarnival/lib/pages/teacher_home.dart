import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        actions:[IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout))
        ]),
        body:Center(
          child: ElevatedButton(
            child: Text("Pick File"),
            onPressed: ()async{
              print("before");
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              print("Hiii");
              if (result != null) {
                print("done");
                File file = File(result.files.single.path!);
              } else {
                print("not done");
                // User canceled the picker
              }
            },
          ),),
        );
  }
  
}