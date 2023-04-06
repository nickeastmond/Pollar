
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pollar/services/auth.dart';
void deleteUserFirestore() async {
  var firestore = FirebaseFirestore.instance; 
    CollectionReference ref = firestore.collection('User');
    // Local ID you want to check
    ref.doc(PollarAuth.getUid()).delete().then(
      (doc) => print("Document deleted"),
      onError: (e) => print("Error updating document $e"),
    );
    PollarAuth.deleteUser();

}