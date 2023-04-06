import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseLogin {
  // If you are listening to changes in authentication state,
  // a new event will be sent to your listeners if succesful.
  static Future<String> firebaseUserLogin(
      String emailAddress, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAddress, password: password);
      debugPrint("Successfully signed in");
      return '';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        debugPrint('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        debugPrint('Wrong password provided for that user.');
      }
      return ("Email or password is incorrect, please type credentials again.");
    }
  }
}
