import 'package:firebase_auth/firebase_auth.dart';
import 'package:pollar/model/user/database/create_user_db.dart';

import '../model/user/pollar_user_model.dart';



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
        print("Created Pollar user");
        PollarUser user = PollarUser.asBasic(credential.user!.uid,emailAddress);
        addUserToFirestore(user);
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