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
  final emailAddress;
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
    return PollarUser.fromData(doc.id, doc.data() ?? {});
  }

  factory PollarUser.fromData(String id, Map<String, dynamic> data) {
    return PollarUser(
      id: id,
      emailAddress: data["emailAddress"],
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



Future<PollarUser> getPollarUser(String uid) async => PollarUser.fromDoc(
    await FirebaseFirestore.instance.collection("PollarUsers").doc(uid).get());
  
Future<String> getEmoji() async  {
    PollarUser user =  await getPollarUser(FirebaseAuth.instance.currentUser!.uid);
    return user.emoji;
}

Future<PollarUser> setEmoji(String emoji) async {
  await FirebaseFirestore.instance
      .collection('PollarUsers')
      .doc(PollarAuth.getUid()!)
      .set({"emoji": emoji}, SetOptions(merge: true));
  return getPollarUser(PollarAuth.getUid()!);
}

Future<PollarUser> setInnerColor(Color color) async {
  await FirebaseFirestore.instance
      .collection('PollarUsers')
      .doc(PollarAuth.getUid()!)
      .set({"innerColor": color.value}, SetOptions(merge: true));
  return getPollarUser(PollarAuth.getUid()!);
}

Future<PollarUser> setOuterColor(Color color) async {
  await FirebaseFirestore.instance
      .collection('PollarUsers')
      .doc(PollarAuth.getUid()!)
      .set({"outerColor": color.value}, SetOptions(merge: true));
  return getPollarUser(PollarAuth.getUid()!);
}

Stream<PollarUser> subscribePollarUser(String uid) async* {
  final snapshots =
      FirebaseFirestore.instance.collection('PollarUsers').doc(uid).snapshots();
  await for (final snapshot in snapshots) {
    yield PollarUser.fromDoc(snapshot);
  }
}

Future<String> getFromSharedPreferences(String key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? val = prefs.getString(key);
  if (val != null) {
    return val;
  } else if (key == 'emoji') {
    saveToSharedPreferences('emoji', defaultEmoji);
    return defaultEmoji;
  }
  print('No value found for key: $key');
  return '';
}

Future<bool> saveToSharedPreferences(String key, String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString(key, value);
}

// For now, only emoji gets saved in shared prefs
// can add more if desired
void fetchFromFirebaseToSharedPreferences() async {
  PollarUser user =  await getPollarUser(FirebaseAuth.instance.currentUser!.uid);
  saveToSharedPreferences("emoji", user.emoji);
}

void changeEmoji(String emoji) {
  setEmoji(emoji);
  saveToSharedPreferences('emoji', emoji);
}