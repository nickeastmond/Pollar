import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:pollar/services/feeds/main_feed_provider.dart';

import '../model/Poll/database/voting.dart';
import '../model/Poll/poll_model.dart';
import '../model/Position/position_adapter.dart';
import '../polls_theme.dart';
import '../services/feeds/feed_provider.dart';
import '../user/main_profile_circle.dart';
import 'bar_graph.dart';
import 'expanded_poll_page.dart';

class PollCard extends StatefulWidget {
  PollCard({Key? key, required this.poll, required this.feedProvider})
      : super(key: key);
  PollFeedObject poll;
  FeedProvider feedProvider;

  @override
  _PollCardState createState() => _PollCardState();
} 

class _PollCardState extends State<PollCard> {
  bool canVote = true;
  int totalVotes = 0;
  int totalComments = 0;
  List<int> counters = [0, 0, 0, 0, 0];
  String locality = "Loading ...";
  String milesAway = "Loading ...";

  Future<List<Placemark>> placemarkLocation(LatLng location) async {
    try {
      return await placemarkFromCoordinates(
          location.latitude, location.longitude);
    } catch (e) {
      return [Placemark()];
    }
  }

  Future<double> distanceFromPoll() async {
    double metersToMilesFactor = 0.000621371;
    Position? physicalLocation =
        await PositionAdapter.getFromSharedPreferences("physicalLocation");
    double lat;
    double lon;
    if (physicalLocation != null) {
      lat = physicalLocation.latitude;
      lon = physicalLocation.longitude;
    } else {
      lat = 0;
      lon = 0;
      debugPrint("LAT LON IS 0");
    }
    double distance = Geolocator.distanceBetween(
        widget.poll.poll.locationData.latitude,
        widget.poll.poll.locationData.longitude,
        lat,
        lon);
    return distance * metersToMilesFactor;
  }

  Future<void> getLocalityString() async {
   
      // setState(() {
      //   locality = (widget.poll.poll.locationName) + "  📍";
      // });
    distanceFromPoll().then((distance) {
      double distanceFromPoll = distance; // Set the initial location data
      setState(() {
        milesAway = ("${distanceFromPoll.toInt()}") + " mi away";
      });
    });
  }

  @override
void didUpdateWidget(PollCard oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (widget.poll.pollId != oldWidget.poll.pollId) {
    getLocalityString();
  }
}

  @override
  void initState() {
    super.initState();
    eligibleVote().then((status) {
      setState(() {
        counters = widget.poll.poll.pollData["answers"]
            .map<int>((e) => int.parse(e["count"].toString()))
            .toList();
        totalComments = widget.poll.poll.numComments;
        totalVotes = widget.poll.poll.votes;
      });
      if (status == false) {
        setState(() {
          List<Map<String, dynamic>> answers = [];
          for (int i = 0;
              i < widget.poll.poll.pollData["answers"].length;
              i++) {
            String answer = widget.poll.poll.pollData["answers"][i]["text"];

            answers.add({"text": answer, "count": counters[i]});
          }
          widget.poll.poll.pollData["answers"] = answers;
        });
      }
    }).then((_)
    {
      getLocalityString();
      print("locality is: ${locality}");
    });
  }

  @override
  void dispose() {
    super.dispose(); // Call super method
  }

  Future<bool> eligibleVote() async {
    bool status = await pollStatus(FirebaseAuth.instance.currentUser!.uid,
        widget.poll.pollId, widget.poll.poll);
    setState(() {
      canVote = status;
    });
    return status;
  }

  Future<void> _onRefresh() async {
    // Simulate a delay while loading new data
    bool hasVoted = await hasUserVoted(
        widget.poll.pollId, FirebaseAuth.instance.currentUser!.uid);
    // Add some new data to the list
    if (mounted) {
      setState(() {
        canVote = hasVoted;
      });
    }

    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance
            .collection('Poll')
            .doc(widget.poll.pollId)
            .get();

    Poll poll = Poll.fromDoc(documentSnapshot);
    setState(() {
      counters = poll.pollData["answers"]
          .map<int>((e) => int.parse(e["count"].toString()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        counters = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ExpandedPollPage(
                pollFeedObj: widget.poll, feedProvider: widget.feedProvider),
          ),
        );
        debugPrint("just left from poll");
        await eligibleVote();
        totalVotes = 0;
        for (int i = 0; i < counters.length; i++) {
          totalVotes += counters[i];
        }
        setState(() {});
      },
      child: PollsTheme(builder: (context, theme) {
        return Container(
          decoration: BoxDecoration(
            color: MediaQuery.of(context).platformBrightness == Brightness.dark
                ? theme.primaryColor
                : theme.cardColor,
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 0),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: 7.5),
                //color: theme.secondaryHeaderColor.withAlpha(200),
                height: 30,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 17.5,
                    ),
                    Text(
                      (widget.poll.poll.locationName) + "  📍",
                      style: TextStyle(
                        height: 1.4,
                        color: Colors.grey.shade800,
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                        // shadows: [
                        //   Shadow(
                        //     blurRadius: 3,
                        //     color: Colors.black,
                        //     offset: Offset(1.0, 1.0),
                        //   ),
                        // ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      milesAway,
                      style: TextStyle(
                        height: 1.4,
                        color: Colors.grey.shade800,
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                        // shadows: [
                        //   Shadow(
                        //     blurRadius: 3,
                        //     color: Colors.black,
                        //     offset: Offset(1.0, 1.0),
                        //   ),
                        // ],
                      ),
                    ),
                    const SizedBox(
                      width: 17.5,
                    ),
                  ],
                ),
              ),
              const Divider(
                thickness: 0.5,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 13,
                        ),
                        MainProfileCircleWidget(
                          emoji: "😄",
                          fillColor: Colors.orange,
                          borderColor: Colors.grey.shade200,
                          size: 35,
                          width: 2.5,
                          emojiSize: 17.5,
                        ),
                        const SizedBox(width: 15),
                        SizedBox(
                          width: 250,
                          //color: Colors.grey.shade900,
                          child: Text(
                            widget.poll.poll.pollData["question"],
                            style: TextStyle(
                              height: 1.4,
                              color: theme.indicatorColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: BarGraph(
                              initalDisplayData: !canVote,
                              numBars:
                                  widget.poll.poll.pollData["answers"].length,
                              height: 35,
                              width: 38,
                              minHeight: 5,
                              counters: widget.poll.poll.pollData["answers"]
                                  .map<int>(
                                      (e) => int.parse(e["count"].toString()))
                                  .toList(),
                              spacing: 2,
                              circleBorder: 0),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.5),
                    Row(
                      children: [
                        const SizedBox(
                          width: 65,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.5),
                          child: Text(
                            widget.poll.poll.numComments.toString(),
                            style: TextStyle(
                              height: 1.5,
                              color: theme.indicatorColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 1.75,
                        ),
                        Icon(
                          Icons.message_rounded,
                          size: 17.5,
                          color: theme.indicatorColor,
                        ),
                        const SizedBox(
                          width: 25,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.5),
                          child: Text(
                            widget.poll.poll.votes.toString(),
                            style: TextStyle(
                              height: 1.5,
                              color: theme.indicatorColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 1.75,
                        ),
                        Icon(
                          Icons.people_rounded,
                          size: 23,
                          color: theme.indicatorColor,
                        ),
                        const SizedBox(
                          width: 27.5,
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: Text(
                            pollText(widget.poll.poll.timestamp),
                            style: TextStyle(
                              height: 1.5,
                              color: theme.indicatorColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

String pollText(DateTime t) {
  final since = DateTime.now().difference(t);
  final pair = since.inMinutes < 60
      ? MapEntry(since.inMinutes, "min")
      : since.inHours < 24
          ? (since.inHours == 1)
              ? MapEntry(since.inHours, "hr")
              : MapEntry(since.inHours, "hrs")
          : (since.inDays == 1)
              ? MapEntry(since.inDays, "day")
              : MapEntry(since.inDays, "days");
  //return "${pair.key} ${pair.value} | ~${poll.milesFrom(currentLocation)}mi";

  return "${pair.key} ${pair.value} ago";
}
