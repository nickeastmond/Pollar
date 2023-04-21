
import 'package:flutter/cupertino.dart';

import 'package:cloud_firestore/cloud_firestore.dart';


bool deleteAllPoll() {
  try {
    FirebaseFirestore.instance.collection('Poll').get().then((querySnapshot) {
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
  