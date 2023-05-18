import 'package:flutter/cupertino.dart';
import 'package:pollar/model/Poll/poll_model.dart';
import 'package:pollar/services/auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';


Future<Poll> getPoll(String pollId) async {
    DocumentSnapshot<Map<String,dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('Poll')
        .doc(pollId)
        .get();
    return Poll.fromDoc(snapshot);
   
}
  
