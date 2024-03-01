// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class Chatbot extends StatefulWidget {
  const Chatbot({Key? key}) : super(key: key);

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  ChatUser myself = ChatUser(id: "1", firstName: "Shivangi");
  ChatUser bot = ChatUser(id: "2", firstName: "bot");
  List<ChatMessage> allMessages = [];
  List<ChatUser> typing=[];
  final ourUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyBYE0mEekGvkn_Q9m3Tm6RgJ4yRU8JqtfE";
  final header = {'Content-Type': 'application/json'};

  Future<void> fetchData(ChatMessage message) async {
    try {
      typing.add(bot);
      allMessages.insert(0, message);
      setState(() {});
      var data = {
        "contents": [
          {"parts": [{"text":message.text}]}
        ]
      };
      final response =
          await http.post(Uri.parse(ourUrl), headers: header, body: jsonEncode(data));
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print("Response: ${result["candidates"][0]["content"]['parts'][0]["text"]}");
        ChatMessage m1 = ChatMessage(user: bot, createdAt:DateTime.now(),
        text: "${result ["candidates"][0]["content"]['parts'][0]["text"]}",
        );
        allMessages.insert(0, m1);
        
      } else {
        print("Failed to fetch data. Error code: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception occurred: $e");
    }
    typing.remove(bot);
    setState(() {
          
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DashChat(
          typingUsers: typing,
          currentUser: myself,
          onSend: (ChatMessage m) {
            fetchData(m);
          },
          messages: allMessages,
        ),
      ),
    );
  }
   
}