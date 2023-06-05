import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../../model/Comment/comment_model.dart';
import '../../model/Poll/poll_model.dart';
import '../../model/user/pollar_user_model.dart';
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

 
  List<String> pollIds = [];


  for (QueryDocumentSnapshot<Map<String, dynamic>> doc in querySnapshot.docs) {
    doc.data()["pollId"];
    pollIds.add(doc.data()["pollId"]);
  }

  int batchSize = 10;
  int end = (pollIds.length / batchSize).ceil();
  if (end > 10) {
    end = 10;
  }
  int curEnd = batchSize;
  for (int i = 0; i < end; i++) {
    int currentBatchSize = curEnd <= pollIds.length ? batchSize : pollIds.length % batchSize;
    final pollSnapshot = await FirebaseFirestore.instance
        .collection('Poll')
        .where(FieldPath.documentId, whereIn: pollIds.sublist(i * batchSize, i * batchSize + currentBatchSize))
        .get();
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in pollSnapshot.docs) {
      final userId = doc.data()["userId"];
    final userSnapshot =
        await FirebaseFirestore.instance.collection('User').doc(userId).get();
      PollarUser user = PollarUser.fromDoc(userSnapshot); 
      PollFeedObject obj = PollFeedObject(Poll.fromDoc(doc), doc.id ,user );
      _items.add(obj);
    }
    curEnd += batchSize;
  }
  _items = _items.toList();
  _items.sort((a, b) => b.poll.timestamp.compareTo(a.poll.timestamp));
  notifyListeners();
  isLoading = false; // Set isLoading to false when fetch is completed

 }
}