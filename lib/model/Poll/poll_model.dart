import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pollar/services/auth.dart';


class Poll {
  final String userId;
  final Map<String,dynamic> locationData;
  final Map<String,dynamic> pollData;
  final double radius;
  int votes = 0;


  Poll({
    required this.userId,
    required this.locationData,
    required this.pollData,
    required this.radius,
  });

  factory Poll.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Poll.fromData(doc.id, doc.data() ?? {});
  }

  factory Poll.fromData(String id, Map<String, dynamic> data) {
    return Poll(
      userId: id,
      locationData: data["locationData"],
      pollData: data["pollData"],
      radius: data["radius"] ?? 20.0
    );
  }

    Map<String, dynamic> getAll() {
    return <String, dynamic> {
        "userId": userId,
        "locationData": locationData,
        "pollData": pollData,
        "radius": radius,
    };
  }
}
