import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommentFeedObj {
  Comment comment;
  String commentId;

  CommentFeedObj(this.comment, this.commentId);
}

class Comment {
  final String uid;
  final String pollId;
  final String userId;
  final String parentCommentId;
  final String text;
  final DateTime timestamp;
  int numLikes = 0;
  int numDislikes = 0;
  bool flagged = false;

  Comment(
      {required this.uid,
      required this.pollId,
      required this.userId,
      required this.parentCommentId,
      required this.text,
      required this.numLikes,
      required this.numDislikes,
      required this.flagged,
      required this.timestamp});

  factory Comment.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Comment.fromDataDoc(doc.data()!["userId"], doc.data() ?? {});
  }

  factory Comment.fromData(String id, Map<String, dynamic> data) {
    return Comment(
        uid: data["uid"],
        userId: id,
        pollId: data["pollId"],
        parentCommentId: data["parentCommentId"] ?? "NONE",
        text: data["text"],
        numLikes: data["numLikes"] ?? 0,
        numDislikes: data["numDislikes"] ?? 0,
        flagged: data["flagged"] ?? false,
        timestamp: data["timestamp"]);
  }

  factory Comment.fromDataDoc(String id, Map<String, dynamic> data) {
    return Comment(
        uid: data["uid"],
        userId: id,
        pollId: data["pollId"],
        parentCommentId: data["parentCommentId"],
        text: data["text"],
        numLikes: data["numLikes"] ?? 0,
        numDislikes: data["numDislikes"] ?? 0,
        flagged: data["flagged"] ?? false,
        timestamp: data["timestamp"].toDate());
  }

  Map<String, dynamic> getAll() {
    return <String, dynamic>{
      "uid": uid,
      "userId": userId,
      "pollId": pollId,
      "parentCommentId": parentCommentId,
      "text": text,
      "numLikes": numLikes,
      "numDislikes": numDislikes,
      "flagged": flagged,
      "timestamp": timestamp
    };
  }
}

Future<bool> createComment(Comment comment) async {
  try {
    var firestore = FirebaseFirestore.instance;
    CollectionReference ref = firestore.collection('Comment');
    await ref.add(comment.getAll());
    debugPrint("Succesfully added comment");
    return true;
  } catch (e) {
    debugPrint("Error adding comment to firestore $e");
    return false;
  }
}

Future<bool> deleteComment(String docId) async {
  try {
    var db = FirebaseFirestore.instance;
    print(docId);
    db.collection("Comment").doc(docId).delete().then(
      (doc) {
        debugPrint("Document deleted");
      },
      onError: (e) => debugPrint("Error updating document $e"),
    );
  } catch (e) {
    debugPrint("Error deleting comment firestore $e");
    return false;
  }
  return false;
}

//TODO: sort by timestamp
Future<List<CommentFeedObj>> getComments(String pollId) async {
  debugPrint("getting comments");
  List<CommentFeedObj> comments = [];

  Completer<List<CommentFeedObj>> completer = Completer<List<CommentFeedObj>>();

  await FirebaseFirestore.instance
      .collection('Comment')
      .where("pollId", isEqualTo: pollId)
      .orderBy("timestamp", descending: true)
      .get()
      .then((val) {
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in val.docs) {
      CommentFeedObj obj = CommentFeedObj(Comment.fromDoc(doc), doc.id);
      comments.add(obj);
    }
  }).then((_) {
    completer.complete(comments);
  }).catchError((error) {
    completer.completeError(error);
  });

  return completer.future;
}

bool deleteAllComment() {
  try {
    FirebaseFirestore.instance
        .collection('Comment')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });

      return true;
    });
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
  return true;
}

bool deleteAllCommentBelongingToUser() {
  try {
    FirebaseFirestore.instance
        .collection('Comment')
        .where("userId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });

      return true;
    });
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
  return true;
}
