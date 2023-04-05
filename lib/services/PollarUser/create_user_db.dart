import '../../model/pollar_user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


void addUserToFirestore(PollarUser pollarUser) async {
  try {
    var firestore = FirebaseFirestore.instance; 

    CollectionReference ref = firestore.collection('User');

    //If for whatever reason a user's authentication data is deleted, and tries to make a new
    //account with the same email, delete the old

    //Get doc where email is equal to the new email
    await ref.where("email", isEqualTo: pollarUser.userData["email"]).get().then(
      (querySnapshot) {
        print("There is an existing user with the same email as incoming email - delting old data");
        for (var docSnapshot in querySnapshot.docs) {
          print('${docSnapshot.id} => ${docSnapshot.data()}');
          ref.doc(docSnapshot.id).delete().then(
            (doc) => print("Document deleted"),
        onError: (e) => print("Error updating document $e"),
    );

        }
      },
      onError: (e) => print("Error completing: $e"),
    );
    


    //Create a new document for a new user
    await ref.doc(pollarUser.uid).set(pollarUser.userData).onError((e, _) => print("Error writing document: $e"));;
    print("Added user to database");
  } catch (e) {
    print("Error creating user in database : ${e}");

  }
  
}