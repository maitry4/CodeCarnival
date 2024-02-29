import 'dart:io';
import 'package:codecarnival/components/course_lectures_ui.dart';
import 'package:codecarnival/pages/teacher_home.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecarnival/components/my_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CourseUi extends StatefulWidget {
  final String CourseName;
  final String TeacherEmail;
  final String Date;
  final String ID;
  int LectureCount;
  CourseUi({
    super.key,
    required this.CourseName,
    required this.TeacherEmail,
    required this.Date,
    required this.ID,
    required this.LectureCount,
  });

  @override
  State<CourseUi> createState() => _CourseUiState();
}

class _CourseUiState extends State<CourseUi> {
  final username = FirebaseAuth.instance.currentUser != null
      ? FirebaseAuth.instance.currentUser!.email
      : 'something';
  String? url;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  // To delete an existing course
  void deleteCourse() {
    // show a dialog box to ask for confirmation
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: const Text("Delete Course"),
              content: const Text("Are you sure you want to delete?"),
              actions: [
                // CANCEL
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel",
                        style: TextStyle(color: Colors.black))),

                // DELETE
                TextButton(
                    onPressed: () async {
                      // delete the comments
                      final commentDoc = await FirebaseFirestore.instance
                          .collection("Courses")
                          .doc(widget.ID)
                          .collection("Lectures")
                          .get();

                      for (var doc in commentDoc.docs) {
                        await FirebaseFirestore.instance
                            .collection("Courses")
                            .doc(widget.ID)
                            .collection("Lectures")
                            .doc(doc.id)
                            .delete();
                      }

                      // delete the post
                      FirebaseFirestore.instance
                          .collection("Courses")
                          .doc(widget.ID)
                          .delete()
                          .then((value) => print("post deleted"))
                          .catchError((error) => print("Failed to delete"));
                      DocumentSnapshot snap = await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(username)
                          .get();

                      int courseCount =
                          (snap.data()! as dynamic)['CourseCount'];
                      courseCount = courseCount - 1;
                      FirebaseFirestore.instance
                          .collection('Users')
                          .doc(username)
                          .update({
                        'CourseCount': courseCount,
                      });
                      // dismis the dialog
                      Navigator.pop(context);
                    },
                    child: const Text("Delete",
                        style: TextStyle(color: Colors.black))),
              ],
            ));
  }

  void uploadFileToStorage(res_file) async {
    // Show circular progress indicator
    showDialog(
      context: context,
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
    if (res_file != null) {
      File file = File(res_file.files.single.path!);
      String fileName = file.path; 
      print(fileName);// Get the file name

      // Upload file to Firebase Storage
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('lectures/$fileName');
      firebase_storage.UploadTask uploadTask = ref.putFile(file);

      // Track the upload task and get the download URL after upload is complete
      uploadTask.whenComplete(() async {
        String downloadURL = await ref.getDownloadURL();
        print('File uploaded to Firebase Storage. Download URL: $downloadURL');
        setState(() {
          url = downloadURL;
        });
      });
      Navigator.of(context).pop();
      // Show circular progress indicator
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20.0),
                  Text("File Successfully Uploaded..."),
                ],
              ),
            ),
          );
        },
      );
    } else {
      // Show circular progress indicator
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20.0),
                  Text("Couldn't Upload file..."),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  // to add a lecture to a course
  void addLecture() {
    // write comment to the firestore
    FirebaseFirestore.instance
        .collection("Courses")
        .doc(widget.ID)
        .collection("Lectures")
        .add({
      "LectureTitle": titleController.text,
      "CreatedBy": username,
      "Description": descriptionController.text,
      "Doubts": {},
      "FileURL": url,
      "UploadTime": Timestamp.now(), //format this later
    });
    // update the comment count
    int newCount = widget.LectureCount + 1;
    FirebaseFirestore.instance
        .collection("Courses")
        .doc(widget.ID)
        .update({'LectureCount': newCount});

    setState(() {
      widget.LectureCount = newCount;
    });
  }
  
  // show dialog box for adding a comment
  void showLectureDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Add Lecture"),
        content: SizedBox(
          height: 250,
          child: Column(
            children: [
              TextField(
                autocorrect: true,
                controller: titleController,
                decoration: const InputDecoration(hintText: "Provide a Title"),
              ),
              TextField(
                autocorrect: true,
                controller: descriptionController,
                decoration: const InputDecoration(
                    hintText: "Provide a meaningful description"),
              ),
              SizedBox(
                height: 2,
              ),
              ElevatedButton(
                child: Text("Upload Notes"),
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();
                  uploadFileToStorage(result);
                },
              ),
              SizedBox(
                height: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        // pop the box
                        Navigator.pop(context);

                        // clear the controller
                        titleController.clear();
                        descriptionController.clear();
                      },
                      child: const Text("Cancel",
                          style: TextStyle(color: Colors.black))),
                  TextButton(
                      onPressed: () {
                        // add comment
                        addLecture();
                        // clear the controller
                        titleController.clear();
                        descriptionController.clear();
                        // pop the box
                        Navigator.pop(context);
                        // Show circular progress indicator
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Container(
                                padding: EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(height: 20.0),
                                    Text("Lecture Created"),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: const Text("Upload",
                          style: TextStyle(color: Colors.black))),
                ],
              ),
              // save button
            ],
          ),
        ),
      ),
    );
  }

  void goToLectures() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseLecutreUi(courseID: widget.ID),
      ),
    );
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
        MyButton(onTap: showLectureDialog, text: "Create Lectures")
      ]),
    );
  }
}
