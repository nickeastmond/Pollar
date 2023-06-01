import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../../model/Poll/poll_model.dart';
import 'feed_provider.dart';



class PollsCreatedProvider extends FeedProvider {
  List<PollFeedObject> _items = []; // Implement items in the subclass
  bool isLoading = false;



  @override
  List<PollFeedObject> get items => _items;
 
  @override
  Future<void> fetchInitial(int limit) async {
    isLoading = true;
    debugPrint("fetchin initial");
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot =
        await FirebaseFirestore.instance.collection('Poll').where("userId",isEqualTo:uid ).limit(limit).get();
    _items = [];

    // Iterate over the documents in the snapshot and check if their circles overlap with the user's circle
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      // Get the document's geopoint and radius
      PollFeedObject obj = PollFeedObject(Poll.fromDoc(doc), doc.id);            
      _items.add(obj); 
    }
    _items = _items.toList();

    _items.sort((a, b) => b.poll.timestamp.compareTo(a.poll.timestamp));
    print("notifyling listerners");
    isLoading = false;
    notifyListeners();
    
  }

  
}
