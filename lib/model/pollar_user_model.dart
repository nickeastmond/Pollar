import 'package:firebase_auth/firebase_auth.dart';

/// Represents a user
class PollarUser {
  var userData = <String, dynamic>{};
  String? uid;

  PollarUser(User? user) {
    uid = user?.uid;
    userData = <String, dynamic>{
      "email": user?.email,
    };

  }
}