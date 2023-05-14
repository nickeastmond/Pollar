import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pollar/services/auth.dart';
import 'package:pollar/model/user/database/get_user_db.dart';
import 'package:shared_preferences/shared_preferences.dart';

const defaultEmoji = "🤪";
final defaultInnerColor = Colors.blue.value;
final defaultOuterColor = Colors.red.value;

class PollarUser {
  final String id;
  final String emailAddress;
  final String emoji;
  final Color innerColor;
  final Color outerColor;
  final int points;

  const PollarUser({
    required this.id,
    required this.emailAddress,
    required this.emoji,
    required this.innerColor,
    required this.outerColor,
    required this.points,
  });

  factory PollarUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    print(doc.data());
    return PollarUser.fromData(doc.id, doc.data() ?? {});
  }

  factory PollarUser.fromData(String id, Map<String, dynamic> data) {
    
    return PollarUser(
      id: id,
      emailAddress: data["email"],
      emoji: data['emoji'] ?? defaultEmoji,
      innerColor: Color(data['innerColor'] ?? defaultInnerColor),
      outerColor: Color(data['outerColor'] ?? defaultOuterColor),
      points: data['points'] ?? 0,
    );
  }
  factory PollarUser.asBasic(String id, String emailAddress) {
    return PollarUser(
      id: id,
      emailAddress: emailAddress,
      emoji: defaultEmoji,
      innerColor: Color( defaultInnerColor),
      outerColor: Color(defaultOuterColor),
      points:0,
    );
  }

  Map<String, dynamic> getAll() {
    return <String, dynamic> {
        "emoji": emoji,
        "email": emailAddress,
        "innerColor": innerColor.value,
        "outterColor": outerColor.value,
        "points": points
    };
  }
}




Future<String> getEmoji() async  {
  PollarUser user =  await getUserById(FirebaseAuth.instance.currentUser!.uid);
  return user.emoji;
}

Future<bool> setEmoji(String emoji) async {
  try {
  
  await FirebaseFirestore.instance
      .collection('User')
      .doc(PollarAuth.getUid()!)
      .set({"emoji": emoji}, SetOptions(merge: true));
      return true;
  
  } catch (e) {
    debugPrint("failed setting user emoji");
    return false;
  }
}

Future<int> getPoints() async {
  PollarUser user =  await getUserById(FirebaseAuth.instance.currentUser!.uid);
  return user.points; 
}

Future<bool> addPoints(int num) async {
  int currentPoints = await getPoints();
  try {
  
  await FirebaseFirestore.instance
      .collection('User')
      .doc(PollarAuth.getUid()!)
      .set({"points": currentPoints + num}, SetOptions(merge: true));
      print('gave user $num points. user now has ${await getPoints()} points');
      return true;
  
  } catch (e) {
    debugPrint("failed to give user points");
    return false;
  }
}

Stream<PollarUser> subscribePollarUser(String uid) async* {
  final snapshots =
      FirebaseFirestore.instance.collection('PollarUsers').doc(uid).snapshots();
  await for (final snapshot in snapshots) {
    yield PollarUser.fromDoc(snapshot);
  }
}

// Note: if retrieving emoji is acting up (gives user the previous user's selected emoji), it is probably
//       because the profile page built before the line could complete
Future<void> fetchUserInfoFromFirebaseToSharedPrefs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('emoji', await getEmoji()); // retrieve set emoji
  prefs.setInt('points', await getPoints()); // retrieve points
  print('fetching from db: points: ${await getPoints()},  emoji:${await getEmoji()}');

}
