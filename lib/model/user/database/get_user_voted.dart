import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:pollar/model/user/pollar_user_model.dart';

Future<Map<String, dynamic>> getTheVoteByIndex(
    String uid, String pollId) async {
  final data = await FirebaseFirestore.instance
      .collection('PollInstance')
      .where('userId', isEqualTo: uid)
      .where('pollId', isEqualTo: pollId)
      .get();
  if (data.docs.isEmpty) {
    return {"vote": null};
  }

  return {
    "vote": data.docs[0].data()["vote"]
  }; // assuming there is only one document matching the query
}
