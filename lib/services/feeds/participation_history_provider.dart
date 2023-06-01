import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../../model/Comment/comment_model.dart';
import '../../model/Poll/poll_model.dart';
import 'feed_provider.dart';



class ParticipationHistoryProvider extends FeedProvider {
  List<PollFeedObject> _items = []; // Implement items in the subclass
  bool isLoading = false;


  @override
  List<PollFeedObject> get items => _items;
 
  @override
 Future<void> fetchInitial(int limit) async {
  isLoading = true; // Set isLoading to true when starting the fetch

  debugPrint("fetching initial");
  String uid = FirebaseAuth.instance.currentUser!.uid;

  // Query the "PollInteraction" collection
  final querySnapshot = await FirebaseFirestore.instance
      .collection('PollInteraction')
      .where('userId', isEqualTo: uid)
      .get();

  final commentSnapshot = await FirebaseFirestore.instance
      .collection('Comment')
      .where('userId', isEqualTo: uid)
      .get();

  List<String> pollIds = [];

  // Get all the pollIds that match the custom id
  for (var doc in querySnapshot.docs) {
    pollIds.add(doc.id);
  }

  for (QueryDocumentSnapshot<Map<String, dynamic>> doc in commentSnapshot.docs) {
    Comment comment = Comment.fromDoc(doc);
    pollIds.add(comment.pollId);
  }

  // Divide the pollIds into batches of 10 elements each
  List<List<String>> batches = [];
  int batchSize = 10;
  for (int i = 0; i < pollIds.length; i += batchSize) {
    int endIndex = i + batchSize;
    if (endIndex > pollIds.length) {
      endIndex = pollIds.length;
    }
    List<String> batch = pollIds.sublist(i, endIndex);
    batches.add(batch);
  }

  // Query the "Poll" collection using the batches of pollIds
  List<QuerySnapshot> pollSnapshots = [];
  for (List<String> batch in batches) {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Poll')
        .where(FieldPath.documentId, whereIn: batch)
        .get();
    pollSnapshots.add(snapshot);
  }

  // Iterate over the documents in the snapshots and add them to _items
  for (QuerySnapshot snapshot in pollSnapshots) {
    for (QueryDocumentSnapshot<Object?> doc in snapshot.docs) {
      PollFeedObject obj = PollFeedObject(Poll.fromDoc(doc as QueryDocumentSnapshot<Map<String, dynamic>>), doc.id);
      _items.add(obj);
    }
  }

  _items = _items.toList();
  _items.sort((a, b) => b.poll.timestamp.compareTo(a.poll.timestamp));
    isLoading = false; // Set isLoading to false when fetch is completed

  notifyListeners();
 }
}