import 'package:cloud_firestore/cloud_firestore.dart';
Future<DocumentSnapshot<Object?>> getUserById(String uid) async {

  DocumentReference documentReference = FirebaseFirestore.instance.collection('User').doc(uid);
  DocumentSnapshot documentSnapshot = await documentReference.get();
  return documentSnapshot;
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
