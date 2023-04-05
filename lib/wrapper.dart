import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login/login_page.dart';
import 'navigation/navigation_page.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  
  
  @override
  Widget build(BuildContext context) {

    //We can use this to check if a user has been authenticated with firebase.
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      print("");
      print("In wrapper.dart:");
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
    return StreamBuilder(
      stream: null,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return const NavigationPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
