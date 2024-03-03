import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:codecarnival/models/question.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
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

void getQuestion()async{
  final res = await fetchData("""provide a coding quiz question in this format: Do not include code neither in the question nor in the options.
  question, provide correct answer index(Assume Index Starts from 0)(should be just a number between 0-3 both inclusive), a) option1, b) option2, c) option3, d) option4
  """);
  print("****");
  
  print(res.split(', ')[0]);
  print(res.split(', ')[1]);
  print(res.split(', ')[2]);
  print(res.split(', ')[3]);
  print(res.split(', ')[4]);
  print(res.split(', ')[5]);

}

const List<Question> questions = [
  Question(
    question: '1. What is the Output of the following Python code?\n x=5\ny=2\nprint(x*y)',
    correctAnswerIndex: 1,
    options: [
      'a) 7',
      'b) 10',
      'c) 25',
      'd) 52',
    ],
  ),
  Question(
    question: '2. Which of the following is not a valid data type in Python?',
    correctAnswerIndex: 2,
    options: [
      'a) int',
      'b) string',
      'c) array',
      'd) float',
    ],
  ),
  Question(
    question: '3. What will be the output of the following JavaScript code?\nvar x = 10;\nvar y = "5";\nconsole.log(x + y);',
    correctAnswerIndex: 1,
    options: [
      'a) 15',
      'b) 105',
      'c) "105"',
      'd) Error',
    ],
  ),
  Question(
    question: '4. What does CSS stand for?',
    correctAnswerIndex: 0,
    options: [
      'a) Cascading Style Sheets',
      'b) Computer Style Sheets',
      'c) Creative Style Sheets',
      'd) Colorful Style Sheets',
    ],
  ),
  Question(
    question: '5. In Java, which keyword is used to declare a constant variable?',
    correctAnswerIndex: 3,
    options: [
      'a) var',
      'b) let',
      'c) const',
      'd) final',
    ],
  ),
];