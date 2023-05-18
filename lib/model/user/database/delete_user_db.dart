
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
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



bool deleteAllUser() {
  try {
    FirebaseFirestore.instance.collection('User').get().then((querySnapshot) {
  querySnapshot.docs.forEach((doc) {
    doc.reference.delete();
  });

  return true;
});
   
  }
  catch (e) {
    debugPrint(e.toString());
    return false;
  }
  return true;
}
  