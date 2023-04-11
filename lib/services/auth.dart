import 'package:firebase_auth/firebase_auth.dart';

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
    // Force the authStateChanges() stream to emit an event immediately
    await Future.delayed(Duration.zero);
  }
}
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
  User? user = auth.currentUser;
  await user?.delete();
  // User account deleted successfully
} catch (e) {
  // An error occurred
  print(e.toString());
}
}

}