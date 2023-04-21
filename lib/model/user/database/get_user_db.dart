import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:pollar/model/user/pollar_user_model.dart';
Future<PollarUser> getUserById(String uid) async {

 DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore.instance
      .collection('User')
      .doc(uid)
      .get();
      
      return PollarUser.fromDoc(doc);
} 

Future<List<QueryDocumentSnapshot>> getUserByEmail(String? emailAddress) async {
    var firestore = FirebaseFirestore.instance; 
    CollectionReference ref = firestore.collection('User');
    // Get a reference to the Firestore database
    // Query for a document with matching email
    final querySnapshot = await ref
        .where('email', isEqualTo: emailAddress)
        .get();
    if (querySnapshot.docs.isEmpty) {
      print('No matching document found');
    } 
  return querySnapshot.docs;
     
} 
