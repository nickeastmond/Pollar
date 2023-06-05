import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pollar/model/Comment/comment_model.dart';
import 'package:pollar/model/Poll/database/delete_all.dart';

class PollarAuth {

User? getUser() {
  final User? user = FirebaseAuth.instance.currentUser;
  // here you write the codes to input the data into firestore
  return user;
}

static Future<void> signOut() async {

  // Get the current user
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User? user = auth.currentUser;

  if (user != null) {
    // Sign out the current user
    await auth.signOut();
    FirebaseAuth.instance.authStateChanges().listen(null); // create new instance of the stream
    // Force the authStateChanges() stream to emit an event immediately
    await Future.delayed(Duration.zero);
  }
}
static bool? isVerified() => FirebaseAuth.instance.currentUser?.emailVerified;
static String? getUid() => FirebaseAuth.instance.currentUser?.uid;
static String? getEmail() => FirebaseAuth.instance.currentUser?.email;
static String? getDisplayName() => FirebaseAuth.instance.currentUser?.displayName;
static String? getPhotoUrl() => FirebaseAuth.instance.currentUser?.photoURL;
static void setDisplayName(String name) async =>
    await FirebaseAuth.instance.currentUser?.updateDisplayName(name);

// check if user is signed in
static bool isUserSignedIn() {
  User? user = FirebaseAuth.instance.currentUser;
  print("user is: ${user}");
  if (user != null) {
    // user is signed in
    // set user's state as authenticated
    return true;
  } else {
    // user is not signed in
    // set user's state as not authenticated
    return false;
  }
}

static void deleteUser() async {
  try {
  FirebaseAuth auth = FirebaseAuth.instance;
  deleteAllCommentBelongingToUser();
  deleteAllPollBelongingToUser();
  User? user = auth.currentUser;
  await user?.delete();
  // User account deleted successfully
} catch (e) {
  // An error occurred
  print(e.toString());
}
}

// sends reset password link to email 
// ISSUE: sends to spam unless user reports as not spam
static void resetPassword() async {
  await FirebaseAuth.instance
    .sendPasswordResetEmail(email: '${PollarAuth.getEmail()}');
}

// Sends an email with verification link
static void sendVerification() async {
  await FirebaseAuth.instance.currentUser!
    .sendEmailVerification();
}


}