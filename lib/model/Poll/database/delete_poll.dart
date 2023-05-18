import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
Future<bool> deletePoll(String pollId) async {
  try {
    var db = FirebaseFirestore.instance; 
    db.collection("Poll").doc(pollId).delete().then(
      (doc) { 
        debugPrint("Poll Document deleted");
        },
      onError: (e) => debugPrint("Error updating document $e"),
    );
  }
  catch (e) {
    debugPrint("Error deleting poll firestore $e");
    return false;
  }
  return true;
}