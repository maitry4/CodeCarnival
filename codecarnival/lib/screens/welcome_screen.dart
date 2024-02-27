import 'package:codecarnival/screens/registration_page.dart';
import 'package:codecarnival/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical:25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/image1.png",
                  height: 300,
                ),
                const SizedBox(height: 20,),
                const Text(
                  "Let's get started",
                  style: TextStyle(
                    fontSize:22,
                    fontWeight:FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10,),
                const Text(
                  "Never a better time than now to start.",
                  style: TextStyle(
                    fontSize:14,
                    color:Colors.black38,
                    fontWeight:FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20,),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CustomButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const RegisterPage()));
                    },
                    text:"Get Started"
                  ),
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}