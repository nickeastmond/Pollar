
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class Report {
  final String pollId;
  final String userId;
  final DateTime timestamp;


  Report({
    required this.pollId,
    required this.userId,
    required this.timestamp
  });

  factory Report.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Report.fromDataDoc(doc.data()!["userId"], doc.data() ?? {});
  }

  factory Report.fromData(String id, Map<String, dynamic> data) {
    return Report(
      userId: id,
      pollId: data["pollId"],
      timestamp: data["timestamp"]
    );
  }

  factory Report.fromDataDoc(String id, Map<String, dynamic> data) {
    return Report(
      userId: id,
      pollId: data["pollId"],
      timestamp: data["timestamp"].toDate()
    );
  }

    Map<String, dynamic> getAll() {
    return <String, dynamic> {
        "userId": userId,
        "pollId": pollId,
        "timestamp": timestamp
    };
  }
}


Future<bool> createReport(Report report) async {
  try {
    var firestore = FirebaseFirestore.instance; 
    CollectionReference ref = firestore.collection('Report');
    await ref.add(report.getAll());
    debugPrint("Succesfully added report");
    return true;
  }
  catch (e) {
    debugPrint("Error adding comment to firestore $e");
    return false;
  }
}

Future<bool> deleteReport(String uid ) async {
  try {
    var db = FirebaseFirestore.instance; 
    db.collection("Report").doc(uid).delete().then(
      (doc) { 
        debugPrint("Report deleted");
        },
      onError: (e) => debugPrint("Error updating document $e"),
    );
  }
  catch (e) {
    debugPrint("Error deleting Report firestore $e");
    return false;
  }
  return false;
}

bool deleteAllReport() {
  try {
    FirebaseFirestore.instance.collection('Report').get().then((querySnapshot) {
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