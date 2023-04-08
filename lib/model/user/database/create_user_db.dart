import 'package:pollar/services/auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../pollar_user_model.dart';


void addUserToFirestore(PollarUser pollarUser) async {
  try {
    var firestore = FirebaseFirestore.instance; 
    CollectionReference ref = firestore.collection('User');

    //TODO: If a user in the firestore shares the same email, but there is no auth account,
    //then we need to delete the old entry and create a new one with the new uid and email.
    // this needs to be done by a backend function because this user doesnt have permission to deleting
    // another  user.
  
    //Create a new document for a new user
    await ref.doc(PollarAuth.getUid()).set(pollarUser.getAll()).onError((e, _) {
      print("Error writing to db ${e}");
      return;
    });
    print("Added user to database");
  } catch (e) {
    print("Error creating user in database : ${e}");

  }
  
}