import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:pollar/model/user/database/create_user_db.dart';
import 'package:flutter/material.dart';
import '../model/user/pollar_user_model.dart';

class FirebaseSignup {
  // If you are listening to changes in authentication state,
  // a new event will be sent to your listeners if succesful.
  static Future<String> firebaseUserSignup(
      String emailAddress, String password) async {
    PollarUser pollarUser;
    try {
      final UserCredential credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAddress, password: password);
      debugPrint("Created Pollar user");
      PollarUser user = PollarUser.asBasic(credential.user!.uid, emailAddress);
      addUserToFirestore(user);
      return '';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        debugPrint('The password provided is too weak.');
        return 'The password provided is too weak';
      } else if (e.code == 'email-already-in-use') {
        debugPrint('The account already exists for that email.');
        return 'The account already exists for that email';
      }
      return 'Error';
    } catch (e) {
      debugPrint(e.toString());
      return e.toString();
    }
  }
}
