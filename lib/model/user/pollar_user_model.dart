import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pollar/services/auth.dart';
import 'package:pollar/model/user/database/get_user_db.dart';
import 'package:shared_preferences/shared_preferences.dart';

const defaultEmoji = "🤪";
const defaultUnlocked = [defaultEmoji, '😂', '😍', '😄'];
const defaultEmojiBgColor = Color.fromARGB(255, 255, 186, 82);
final defaultInnerColor = Colors.blue.value;
final defaultOuterColor = Colors.white.value;

int? points = 0;
int? sprefPoints = -1;

class PollarUser {
  final String id;
  final String emailAddress;
  final String emoji;
  final Color emojiBgColor;
  final Color innerColor;
  final Color outerColor;
  final int points;
  final List<dynamic> unlocked;

  const PollarUser({
    required this.id,
    required this.emailAddress,
    required this.emoji,
    required this.emojiBgColor,
    required this.innerColor,
    required this.outerColor,
    required this.points,
    required this.unlocked,
  });

  factory PollarUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return PollarUser.fromData(doc.id, doc.data() ?? {});
  }

  factory PollarUser.fromData(String id, Map<String, dynamic> data) {
    
    return PollarUser(
      id: id,
      emailAddress: data["email"],
      emoji: data['emoji'] ?? defaultEmoji,
      emojiBgColor: Color(data['emojiBgColor']) ?? defaultEmojiBgColor,
      innerColor: Color(data['innerColor'] ?? defaultInnerColor),
      outerColor: Color(data['outerColor'] ?? defaultOuterColor),
      points: data['points'] ?? 0,
      unlocked: data['unlocked'] ?? defaultUnlocked,
    );
  }
  factory PollarUser.asBasic(String id, String emailAddress) {
    return PollarUser(
      id: id,
      emailAddress: emailAddress,
      emoji: defaultEmoji,
      emojiBgColor: defaultEmojiBgColor,
      innerColor: Color( defaultInnerColor),
      outerColor: Color(defaultOuterColor),
      points: 0,
      unlocked: defaultUnlocked,
    );
  }

  Map<String, dynamic> getAll() {
    return <String, dynamic> {
        "emoji": emoji,
        "email": emailAddress,
        "innerColor": innerColor.value,
        "outterColor": outerColor.value,
        "points": points,
        "unlocked": unlocked,
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
      debugPrint("Set emoji");
      return true;
  
  } catch (e) {
    debugPrint("failed setting user emoji: ${e}");
    return false;
  }
}

Future<bool> setEmojiBgColor(int color) async {
  try {
  
  await FirebaseFirestore.instance
      .collection('User')
      .doc(PollarAuth.getUid()!)
      .set({"emojiBgColor": color}, SetOptions(merge: true));
      debugPrint("Set BG Color");
      return true;
  
  } catch (e) {
    debugPrint("failed setting user emoji bg color");
    return false;
  }  
}

Future<int> getPoints() async {
  PollarUser user =  await getUserById(FirebaseAuth.instance.currentUser!.uid);
  return user.points; 
}

Future<bool> addPoints(int num) async {
  final prefs = await SharedPreferences.getInstance();

  // update shared prefs
  prefs.setInt('points',
      sprefPoints! + num);
  sprefPoints = prefs.getInt('points')!;
  points = sprefPoints;
  debugPrint('gave user $num points');

  try {
  
    // update for firebase
    await FirebaseFirestore.instance
      .collection('User')
      .doc(PollarAuth.getUid()!)
      .set({"points": points}, SetOptions(merge: true));
    return true;
  
  } catch (e) {
    debugPrint("failed to give user points");
    print(e);
    return false;
  }
}

Future<List<dynamic>> getUnlockedAssets() async {
  PollarUser user =  await getUserById(FirebaseAuth.instance.currentUser!.uid);

  return user.unlocked;
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

Future<bool> buyEmoji(int cost, String emoji) async {
  final prefs = await SharedPreferences.getInstance();
  try {
  
  await FirebaseFirestore.instance
      .collection('User')
      .doc(PollarAuth.getUid()!)
      .set({"unlocked": FieldValue.arrayUnion([emoji])}, SetOptions(merge: true));


    try {
      await FirebaseFirestore.instance
        .collection('User')
        .doc(PollarAuth.getUid()!)
        .set({"points": sprefPoints! - cost}, SetOptions(merge: true));

        // setting new value of points for display
        prefs.setInt('points', sprefPoints! - cost);
        sprefPoints = prefs.getInt('points')!;
        points = sprefPoints;
    } catch (e) {
      debugPrint("failed deducting points for exchange");
      return false;
    }

      return true;
  
  } catch (e) {
    debugPrint("failed buying emoji");
    print(e);
    return false;
  }
}

