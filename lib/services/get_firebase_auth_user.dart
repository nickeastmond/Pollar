import 'package:firebase_auth/firebase_auth.dart';

User? get_firebase_auth_user() {
  final User? user = FirebaseAuth.instance.currentUser;
  // here you write the codes to input the data into firestore
  return user;
}