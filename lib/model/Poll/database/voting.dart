import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';


// There is a cloud function that deletes all interaections upon poll deletion
Future<bool> pollInteraction(int vote, String userId, String pollId) async
{
  bool canVote = await hasUserVoted(pollId, userId);
  if (canVote == false)
  {
    debugPrint("Already Voted");
    return false;
  }

  voteOnPoll(pollId, userId, vote);
  debugPrint("Voted");

  return true;
 
}

 void voteOnPoll(String pollId, String userId, int vote) {
    final CollectionReference pollInteractionsCollection = FirebaseFirestore.instance.collection('PollInteraction');

    pollInteractionsCollection.add({
      'pollId': pollId,
      'userId': userId,
      'vote': vote,
    });
}

Future<bool> hasUserVoted(String pollId, String userId) async {
  final CollectionReference pollInteractionCollection = FirebaseFirestore.instance.collection('PollInteraction');
  final QuerySnapshot pollInteractionQuerySnapshot = await pollInteractionCollection.where('pollId', isEqualTo: pollId).where('userId', isEqualTo: userId).get();
  return pollInteractionQuerySnapshot.docs.isEmpty;
}


