import 'dart:convert';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  ChatUser myself = ChatUser(id: "1", firstName: "Shivangi");
  ChatUser bot = ChatUser(id: "2", firstName: "bot");
  List<ChatMessage> allMessages = [];
  List<ChatUser> typing=[];
  final ourUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyBYE0mEekGvkn_Q9m3Tm6RgJ4yRU8JqtfE";
  final header = {'Content-Type': 'application/json'};
  final username = FirebaseAuth.instance.currentUser != null
      ? FirebaseAuth.instance.currentUser!.email
      : 'something';
  final lecturetitleController = TextEditingController();
  final lectureDescriptionController = TextEditingController();
  String? url = "";
  
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


Future<String> fetchData(String message) async {
  try {
    var data = {
      "contents": [
        {"parts": [{"text": message}]}
      ]
    };
    final response = await http.post(Uri.parse(ourUrl), headers: header, body: jsonEncode(data));
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


  void addLecture() async {
    print("Inside addLecture: ");
    print(url);
    if(lecturetitleController.text.isEmpty ||
      lectureDescriptionController.text.isEmpty || url!.isEmpty){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Please fill in all fields and upload a file"),
      duration: Duration(seconds: 2),
    ));
    return; 
    }
    else
    {final res= await fetchData("Can you provide 3 reference websites for this lecture?Title: ${lecturetitleController.text} Description: ${lectureDescriptionController.text}Provide them in this format: FORMAT: 1. <URL> in new line 2. <URL> in new line 3. <URL>");
    print("****");
    print(lecturetitleController.text);
    print(lectureDescriptionController.text);

    FirebaseFirestore.instance
        .collection("Courses")
        .doc(widget.ID)
        .collection("Lectures")
        .add({
      "LectureTitle": lecturetitleController.text,
      "CreatedBy": username,
      "Description": lectureDescriptionController.text,
      "Doubts": {},
      "FileURL": url,
      "Reference": res,
      "UploadTime": Timestamp.now(), //format this later
    });
    Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Lecture created successfully"),
                duration: Duration(seconds: 2),
              ));}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MyTextField(
                controller: lecturetitleController,
                hintText: "Provide Lecture Title",
                obscureText: false),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MyTextField(
                controller: lectureDescriptionController,
                hintText: "Provide a meaningful Lecture Description",
                obscureText: false),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
            child: Text("Upload Notes"),
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              uploadFileToStorage(result);
            },
          ),
          const SizedBox(
            height: 10,
          ),
          MyButton(
            onTap: () {
              addLecture();
              // clear the controller
              // lecturetitleController.clear();
              // lectureDescriptionController.clear();
              // pop the box
              
            },
            text: "Add a New Lecture",
          ),
        ],
      ),
    );
  }
}
