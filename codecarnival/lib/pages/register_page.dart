import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecarnival/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:codecarnival/components/my_button.dart';
import 'package:codecarnival/components/my_textfield.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();
  Set<dynamic> selectedValue = {}; // Example: empty set for initial selection
  List<ButtonSegment> segments = [
    const ButtonSegment(label: Text('Student'), value: 'Student'),
    const ButtonSegment(label: Text('Teacher'), value: 'Teacher'),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedValue = {};
  }

  // sign user up method
  void signUserUp() async {
    // show loading circle
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
    // Check for user existence first
    final list = await FirebaseAuth.instance
        .fetchSignInMethodsForEmail(emailController.text.trim());
    print("***********");
    print(list);
    print(list.isNotEmpty);
    if (list.isEmpty) {
      if (selectedValue.isNotEmpty) {
        
      // try creating the user
      try {
        // check if password is same as confirm paswword. and both of them are greater than 6 characters
        final passLen = passwordController.text.length;
        if (passwordController.text == confirmpasswordController.text &&
            passLen >= 6) {
          // create a user
          UserCredential userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: emailController.text,
                  password: passwordController.text);

          // after that create a new document in cloud firebase called Users
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(userCredential.user!.email)
              .set({
            'username': emailController.text.split('@')[0],
            'bio': 'empty bio',
            'userHasCompletedOnboarding': false,
            'Role': selectedValue.first,
            'CourseCount':0,
            'LectureCount':0,
            'Courses': [],
          });

          Navigator.pop(context);
        } else {
          // show error message
          Navigator.pop(context);
          invalidCredential(
              "Password(s) don't match! Or is less than 6 characters");
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-credential') {
          invalidCredential(e.code);
          Navigator.pop(context);
        } else if (e.code == 'auth/email-already-in-use') {
          invalidCredential(e.code);
          Navigator.pop(context);
        } else {
          invalidCredential(e.code);
          Navigator.pop(context);
        }
      }
    } else{
      invalidCredential("Select a Role first");
    }
    }else {
      invalidCredential("User Already Exists!!");
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => LoginPage(
                    onTap: () {},
                  )));
    }
    // pop the loading circle
  }

  void invalidCredential(error) {
      if (error == 'invalid-credential') {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Class Deleted Successfully"),
        duration: Duration(seconds: 2),
      ));
      }
      else{
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        duration: const Duration(seconds: 2),
      ));
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: ListView(
            children: [
              const SizedBox(height: 25),

              // logo
              SvgPicture.asset(
                'lib/images/main_icon.svg',
                height: 150,
              ),

              const SizedBox(height: 25),

              // Let's create an account for you
              Center(
                child: Text(
                  'Join the community of action takers!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // email textfield
              Padding(
                padding: const EdgeInsets.only(left:18.0, right:18.0, top:18.0),
                child: MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.all(18.0),
                child: SegmentedButton(
                  emptySelectionAllowed: true,
                  onSelectionChanged: (newValue) {
                    // Update the selection variable with the new value(s)
                    setState(() {
                      selectedValue = newValue;
                    });
                    if (selectedValue.first == 'Student') {
                      print("Student");
                    } else if (selectedValue.first == 'Teacher') {
                      print("Teacher");
                    }
                  },
                  segments: segments,
                  selected: selectedValue,
                ),
              ),
              const SizedBox(height: 10),

              // password textfield
              Padding(
                padding: const EdgeInsets.only(left:18.0, right:18.0),
                child: MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
              ),

              const SizedBox(height: 10),

              // confirm password textfield
              Padding(
                padding: const EdgeInsets.only(left:18.0, right:18.0, top:18.0),
                child: MyTextField(
                  controller: confirmpasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
              ),

              const SizedBox(height: 25),

              // sign in button
              MyButton(
                text: "Sign up",
                onTap: signUserUp,
              ),

              const SizedBox(height: 50),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 30,
              ),
              // not a member? register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an Account?',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      'Login now',
                      style: TextStyle(
                        color: Color(0xFF014a97),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
