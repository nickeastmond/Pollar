import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pollar/services/auth.dart';

Future<List<QueryDocumentSnapshot>> getUserById(String uid) async {
    var firestore = FirebaseFirestore.instance; 
    CollectionReference ref = firestore.collection('User');
    // Get a reference to the Firestore database
    // Query for a document with matching ID
    final querySnapshot = await ref
        .where('id', isEqualTo: uid)
        .get();
    if (querySnapshot.docs.isEmpty) {
      print('No matching document found');
    } else {
      querySnapshot.docs.forEach((doc) {
        print('Document with ID ${doc.id} found');
        
      });
  }
  return querySnapshot.docs;
     
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
