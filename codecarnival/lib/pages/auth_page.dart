import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecarnival/pages/home_page.dart';
import 'package:codecarnival/pages/login_or_register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // logged in
            if(snapshot.hasData) {
              return HomePage();
            }
          // not logged in
            else {
              return LoginOrRegisterPage();
            }

        }
      );
  }
}