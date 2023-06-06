import 'dart:math';

import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../../model/Poll/poll_model.dart';
import '../../model/user/pollar_user_model.dart';
import 'feed_provider.dart';

const algoliaApplicationId = "PURDN21VI7";
const algoliaApiKey = "a448e15792f1a9060293200b00101317";



class GlobalFeedProvider extends FeedProvider {
  List<PollFeedObject> _items = []; // Implement items in the subclass
  bool isLoading = false;
  bool isSearching = false; // Flag to track search operation state




  @override
  List<PollFeedObject> get items => _items;
 
  @override
  Future<void> fetchInitial(int limit) async {
    isLoading = true;
    debugPrint("fetchin initial");
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot =
        await FirebaseFirestore.instance.collection('Poll').
        limit(limit).get();
    _items = [];

    // Iterate over the documents in the snapshot and check if their circles overlap with the user's circle
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      // Get the document's geopoint and radius
      final userId = doc.data()["userId"];
    final userSnapshot =
        await FirebaseFirestore.instance.collection('User').doc(userId).get();
      PollarUser user = PollarUser.fromDoc(userSnapshot); 
      PollFeedObject obj = PollFeedObject(Poll.fromDoc(doc), doc.id ,user );         
      _items.add(obj); 
    }
    _items = _items.toList();
        _items.sort((a, b) => b.poll.timestamp.compareTo(a.poll.timestamp));


    print("notifyling listerners");
    isLoading = false;
    notifyListeners();
    
  }

Future<void> fetchBySearchText(String searchText) async {
      if (isSearching)
      {
        return;
      }
      if (searchText.isEmpty)
      {
       fetchInitial(100).then((value) => null);
       isSearching = false;
       isLoading = false;
       return;
      }
      _items = [];
      isLoading = true;
      isSearching = true;
    debugPrint("fetchin global");
    const Algolia algolia = Algolia.init(
          applicationId: algoliaApplicationId,
          apiKey: algoliaApiKey,
        );

    AlgoliaQuery query = algolia.instance.index('Pollar_Poll_Question_Index').query(searchText)
    .setPage(0)
  ..setHitsPerPage(10);
AlgoliaQuerySnapshot snapshot = await query.getObjects();

List<String> objectIDs = snapshot.hits.map((hit) => hit.objectID).toList();
if (objectIDs.length > 10) {
  objectIDs = objectIDs.sublist(0, 10);
}


    if (objectIDs.isEmpty)
    {
      _items = [];
      isLoading = false;
      isSearching = false;
      return;
    }
    print(objectIDs);
    final firestoreSnapshot = await FirebaseFirestore.instance
        .collection('Poll')
        .where(FieldPath.documentId, whereIn: objectIDs)
        .get();
    // Iterate over the documents in the snapshot and check if their circles overlap with the user's circle
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in firestoreSnapshot.docs) {
      final userId = doc.data()["userId"];
    final userSnapshot =
        await FirebaseFirestore.instance.collection('User').doc(userId).get();
      PollarUser user = PollarUser.fromDoc(userSnapshot); 
      PollFeedObject obj = PollFeedObject(Poll.fromDoc(doc), doc.id ,user );         
      _items.add(obj); 
    }
    _items = _items.toList();

    //For now just sort by votes.
    _items.sort((a, b) => a.poll.votes.compareTo(a.poll.votes));

    
    print("notifyling listerners");
    isLoading = false;
    isSearching = false;
    notifyListeners();

  }


  
}
