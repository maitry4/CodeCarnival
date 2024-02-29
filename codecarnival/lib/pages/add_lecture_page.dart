import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecarnival/components/my_button.dart';
import 'package:codecarnival/components/my_textfield.dart';
import 'package:codecarnival/helper/helper_method.dart';
import 'package:codecarnival/pages/my_course_page.dart';
import 'package:codecarnival/pages/teacher_home.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class AddLecturePage extends StatefulWidget {
  final String ID;
  int LectureCount;
  AddLecturePage({super.key, required this.ID, required this.LectureCount});

  @override
  State<AddLecturePage> createState() => _AddLecturePageState();
}

class _AddLecturePageState extends State<AddLecturePage> {
  final username = FirebaseAuth.instance.currentUser != null
      ? FirebaseAuth.instance.currentUser!.email
      : 'something';
  final lecturetitleController = TextEditingController();
  final lecutreDescriptionController = TextEditingController();
  String? url = "";
  String reference = "";
  void getReference() {
    print("get reference");
    setState(() {
      reference = "the references that we get";
    });
  }

  void uploadFileToStorage(res_file) async {
    // Show circular progress indicator
    if (res_file != null) {
      File file = File(res_file.files.single.path!);
      String fileName = file.path;
      print(fileName); // Get the file name

      // Show circular progress indicator
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dialog dismissal
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20.0),
                  Text("Uploading file..."),
                ],
              ),
            ),
          );
        },
      );

      try {
        // Upload file to Firebase Storage
        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('lectures/$fileName');
        firebase_storage.UploadTask uploadTask = ref.putFile(file);

        // Track the upload task and get the download URL after upload is complete
        uploadTask.whenComplete(() async {
          try {
            String downloadURL = await ref.getDownloadURL();
            print(
                'File uploaded to Firebase Storage. Download URL: $downloadURL');

            // Dismiss circular progress indicator
            Navigator.of(context).pop();

            // Update UI with download URL
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("File successfully uploaded"),
              duration: Duration(seconds: 2),
            ));

            // Update UI with download URL
            setState(() {
              url = downloadURL;
              print(url);
            });
          } catch (error) {
            print("Error getting download URL: $error");
            // Dismiss circular progress indicator
            Navigator.of(context).pop();

            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Failed to get download URL"),
              duration: Duration(seconds: 2),
            ));
          }
        });
      } catch (error) {
        print("Error uploading file: $error");
        // Dismiss circular progress indicator
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to upload file"),
          duration: Duration(seconds: 2),
        ));
      }
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("No file selected"),
        duration: Duration(seconds: 2),
      ));
    }
  }

  void addLecture() {
    print("Inside addLecture: ");
    print(url);
    getReference();
    // write comment to the firestore
    FirebaseFirestore.instance
        .collection("Courses")
        .doc(widget.ID)
        .collection("Lectures")
        .add({
      "LectureTitle": lecturetitleController.text,
      "CreatedBy": username,
      "Description": lecutreDescriptionController.text,
      "Doubts": {},
      "FileURL": url,
      "Reference": reference,
      "UploadTime": Timestamp.now(), //format this later
    });
    // update the comment count
    print(widget.LectureCount);
    int newCount = widget.LectureCount + 1;
    FirebaseFirestore.instance
        .collection("Users")
        .doc(username)
        .update({'LectureCount': newCount});

    setState(() {
      widget.LectureCount = newCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MyTextField(
              controller: lecturetitleController,
              hintText: "Provide Lecture Title",
              obscureText: false),
          MyTextField(
              controller: lecutreDescriptionController,
              hintText: "Provide a meaningful Lecture Description",
              obscureText: false),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            child: Text("Upload Notes"),
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              uploadFileToStorage(result);
            },
          ),
          MyButton(
            onTap: () {
              addLecture();
              // clear the controller
              lecturetitleController.clear();
              lecutreDescriptionController.clear();
              // pop the box
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Lecture created successfully"),
              duration: Duration(seconds: 2),
            ));
            },
            text: "Add a New Lecture",
          ),
        ],
      ),
    );
  }
}
