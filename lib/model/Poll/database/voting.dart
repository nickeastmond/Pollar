import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:pollar/model/Poll/poll_model.dart';
import 'package:pollar/model/Position/position_adapter.dart';
import 'package:pollar/polls/create_poll_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pollar/services/feeds/feed_provider.dart';

Future<bool> geoPointsDistance(Position p1, Position p2, double r1) async {
  double metersToMilesFactor = 0.000621371;
  // Calculate the distance between the two points
  double distance = Geolocator.distanceBetween(
      p1.latitude, p1.longitude, p2.latitude, p2.longitude);
  // Check if the distance is less than or equal to the radius
  return (distance * metersToMilesFactor) <= (r1);
}

Future<bool> pollStatus(String userId, String pollId, Poll currentPoll) async {
  final pollLocation = Position(
      latitude: currentPoll.locationData.latitude,
      longitude: currentPoll.locationData.longitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0);

  bool? locationGranted =
      await PositionAdapter.getLocationStatus("locationGranted");
  bool canVote = await hasUserVoted(pollId, userId);
  Position? physicalLocation =
      await PositionAdapter.getFromSharedPreferences("physicalLocation");
  final bool inRange = await geoPointsDistance(
      physicalLocation!, pollLocation, currentPoll.radius);

  if (locationGranted == true &&
      canVote &&
      (inRange || currentPoll.radius == 999)) {
    debugPrint("Can Vote");
    return true;
  } else {
    if (locationGranted == false) {
      debugPrint("Permissions not Granted");
    } else if (canVote == false) {
      debugPrint("Already Voted");
    } else if (inRange == false) {
      debugPrint("Out of Range");
    }
    return false;
  }
}

// There is a cloud function that deletes all interaections upon poll deletion
Future<bool> pollInteraction(
    int vote, String userId, String pollId, Poll currentPoll) async {
  bool? canVote = await pollStatus(userId, pollId, currentPoll);

  if (canVote) {
    voteOnPoll(pollId, userId, vote);
  } else {
    return false;
  }
  return true;
}

Future<void> voteOnPoll(String pollId, String userId, int vote) async {
  final CollectionReference pollInteractionsCollection =
      FirebaseFirestore.instance.collection('PollInteraction');

  await pollInteractionsCollection.add({
    'pollId': pollId,
    'userId': userId,
    'vote': vote,
  });
}

Future<bool> hasUserVoted(String pollId, String userId) async {
  final CollectionReference pollInteractionCollection =
      FirebaseFirestore.instance.collection('PollInteraction');
  final QuerySnapshot pollInteractionQuerySnapshot =
      await pollInteractionCollection
          .where('pollId', isEqualTo: pollId)
          .where('userId', isEqualTo: userId)
          .get();
  return pollInteractionQuerySnapshot.docs.isEmpty;
}
