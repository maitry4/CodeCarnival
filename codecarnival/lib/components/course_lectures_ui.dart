import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecarnival/components/my_button.dart';
import 'package:codecarnival/helper/helper_method.dart';
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
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No lectures available.'),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var lecture = snapshot.data!.docs[index];
            var lectureData = lecture.data() as Map<String, dynamic>;
            // Build your UI here using lectureData
            return Column(
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ListTile(
                  title: Text(lectureData['LectureTitle']),
                  subtitle: Text(lectureData['Description']),
                  // Add more fields as needed
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    children: [
                      Text("DownLoad Notes"),
                      IconButton(
                        icon: Icon(Icons.open_in_new),
                        onPressed: () => 
                        launchUrl(Uri.parse(lectureData['FileURL'])
                        ),
                      ),
                    ],
                  ),
                ),
                  
                
                
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left:8.0),
                      child: Text("Created By: ${lectureData['CreatedBy'].split('@')[0]}"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right:8.0, left:8.0),
                      child: Text(formatDate(lectureData['UploadTime']), style: TextStyle(color:Colors.grey, fontSize:13),),
                    ),
                  ],
                ),
                
                MyButton(onTap: (){}, text: "View Reference"),
              ],
            );

          },
        );
      },

    ),
    );
  }
}