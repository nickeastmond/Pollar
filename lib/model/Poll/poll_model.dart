
import 'package:cloud_firestore/cloud_firestore.dart';

class Poll {
  final String userId;
  final Map<String,dynamic> locationData;
  final Map<String,dynamic> pollData;
  final double radius;
  int votes = 0;
  int numComments = 0;
  DateTime timestamp;


  Poll({
    required this.userId,
    required this.locationData,
    required this.pollData,
    required this.radius,
    required this.votes,
    required this.numComments,
    required this.timestamp
  });

  factory Poll.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Poll.fromDataDoc(doc.data()!["userId"], doc.data() ?? {});
  }

  factory Poll.fromData(String id, Map<String, dynamic> data) {
    return Poll(
      userId: id,
      locationData: data["locationData"],
      pollData: data["pollData"],
      radius: data["radius"] ?? 20.0,
      votes: data["votes"] ?? 0,
      timestamp: data["timestamp"],
      numComments: data["numComments"] ?? 0
    );
  }

  factory Poll.fromDataDoc(String id, Map<String, dynamic> data) {
    return Poll(
      userId: id,
      locationData: data["locationData"],
      pollData: data["pollData"],
      radius: data["radius"] ?? 20.0,
      votes: data["votes"] ?? 0,
      timestamp: data["timestamp"].toDate(),
      numComments: data["numComments"] ?? 0
    );
  }

    Map<String, dynamic> getAll() {
    return <String, dynamic> {
        "userId": userId,
        "locationData": locationData,
        "pollData": pollData,
        "radius": radius,
        "numComments": numComments,
        "votes": votes,
        "timestamp": timestamp
    };
  }
}
