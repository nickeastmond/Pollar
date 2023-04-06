import 'package:firebase_auth/firebase_auth.dart';

class FirebaseLogin {
    // If you are listening to changes in authentication state, 
    // a new event will be sent to your listeners if succesful.
    static Future<void> firebaseUserLogin(String emailAddress, String password) async {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailAddress,
          password: password
        );
        print("Successfully signed in");
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
        }
      }
      

    }
      
}