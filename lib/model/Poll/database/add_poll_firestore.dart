import 'package:flutter/cupertino.dart';
import 'package:pollar/model/Poll/poll_model.dart';
import 'package:pollar/services/auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';


Future<bool> addPollToFirestore(Poll poll) async {
  try {
    var firestore = FirebaseFirestore.instance; 
    CollectionReference ref = firestore.collection('Poll');

  
    //Create a new document for a new user
    await ref.add(poll.getAll());
    debugPrint("Succesfully added poll");
    return true;
  }
  catch (e) {
    debugPrint(e.toString());
    return false;
  }
}
  
