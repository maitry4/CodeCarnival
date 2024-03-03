import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;  
import 'package:url_launcher/url_launcher.dart';

class CourseLecutreUi extends StatefulWidget {
  final String courseID;
  const CourseLecutreUi({super.key, required this.courseID});

  @override
  State<CourseLecutreUi> createState() => _CourseLecutreUiState();
}

class _CourseLecutreUiState extends State<CourseLecutreUi> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Courses')
            .doc(widget.courseID)
            .collection('Lectures')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No lectures available.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var lecture = snapshot.data!.docs[index];
              var lectureData = lecture.data() as Map<String, dynamic>;
              // Build your UI here using lectureData
              return Padding(
                padding: const EdgeInsets.only(top:18.0, left:18.0, right:18.0, bottom:10.0),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    // color: const Color(0xffedeee9),
                    borderRadius: BorderRadius.circular(12),
                              image: const DecorationImage(
                      image: AssetImage("lib/images/lecture_background1.jpg"),
                      fit: BoxFit.cover,
                      opacity: 0.45,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title
                      Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(132, 255, 255, 255),
                            border: Border.all(
                              
                              width: 2,
                              color: const Color(0xFF014a97),
                              
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                              'LectureTitle:- ${lectureData['LectureTitle']}                   ',
                              style: const TextStyle(fontSize: 20))),
                      // Text(lectureData['LectureTitle']),
                      Text('Description:- ${lectureData['Description']}',
                          style: TextStyle(color: Colors.grey[800])),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            padding: const EdgeInsets.all(8.0),
                            
                            decoration: BoxDecoration(
                              color: Color.fromARGB(132, 255, 255, 255),
                              border: Border.all(
                                width: 2,
                                color: const Color(0xFF014a97),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: FutureBuilder<String>(
                              future: fetchData(
                                  'Can you provide an interesting one line fact or joke related to ${lectureData['LectureTitle']}'), // Call fetchData here
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator(); // Return loading indicator while fetching data
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  // If data is fetched successfully, display it
                                  return Text(snapshot.data ??
                                      ''); // Display fetched data
                                }
                              },
                            )),
                      ),

                      const Text("References", style: TextStyle(fontSize: 19)),
                      GestureDetector(
                          onTap: () {
                            final x = lectureData['Reference'].split('\n');
                            final updatedX = x.map(
                                (url) => url.replaceAll(RegExp(r'\d+\. '), ''));
                            print(lectureData['Reference'].runtimeType);
                            final simpleList = updatedX.toList();
                            print(simpleList.runtimeType);
                            launchUrl(Uri.parse(simpleList[0]));
                          },
                          child: Text(lectureData['Reference'].split('\n')[0])),
                      GestureDetector(
                          onTap: () {
                            final x = lectureData['Reference'].split('\n');
                            final updatedX = x.map(
                                (url) => url.replaceAll(RegExp(r'\d+\. '), ''));
                            print(lectureData['Reference'].runtimeType);
                            final simpleList = updatedX.toList();
                            print(simpleList.runtimeType);
                            launchUrl(Uri.parse(simpleList[1]));
                          },
                          child: Text(lectureData['Reference'].split('\n')[1])),
                      GestureDetector(
                          onTap: () {
                            final x = lectureData['Reference'].split('\n');
                            final updatedX = x.map(
                                (url) => url.replaceAll(RegExp(r'\d+\. '), ''));
                            print(lectureData['Reference'].runtimeType);
                            final simpleList = updatedX.toList();
                            print(simpleList.runtimeType);
                            launchUrl(Uri.parse(simpleList[2]));
                          },
                          child: Text(lectureData['Reference'].split('\n')[2])),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          children: [
                            const Text("DownLoad Notes"),
                            IconButton(
                              icon: const Icon(Icons.open_in_new),
                              onPressed: () =>
                                  launchUrl(Uri.parse(lectureData['FileURL'])),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 240.0),
                        child: Text(
                            "Created By: ${lectureData['CreatedBy'].split('@')[0]}"),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
