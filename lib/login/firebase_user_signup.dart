import 'package:firebase_auth/firebase_auth.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import '../model/pollar_user_model.dart';
import '../services/PollarUser/create_user_db.dart';


class FirebaseSignup {
    // If you are listening to changes in authentication state, 
    // a new event will be sent to your listeners if succesful.
    static Future<void> firebaseUserSignup(String emailAddress, String password) async {
      PollarUser pollarUser;
      try {
        final UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailAddress,
          password: password,
        );

        User? user = credential.user;
        
        pollarUser = PollarUser(user);
        print("Created Pollar user");
        addUserToFirestore(pollarUser);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
        }
      } catch (e) {
        print(e);
      }
    }
}