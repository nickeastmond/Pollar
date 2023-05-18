import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pollar/navigation/feed_page.dart';

import '../model/Poll/database/voting.dart';
import '../model/Poll/poll_model.dart';
import '../polls_theme.dart';
import '../user/main_profile_circle.dart';
import 'bar_graph.dart';
import 'expanded_poll_page.dart';

class PollCard extends StatefulWidget {
  PollCard({
    Key? key,
    required this.poll,
  }) : super(key: key);
  PollFeedObject poll;

  @override
  _PollCardState createState() => _PollCardState();
}

class _PollCardState extends State<PollCard> {
  bool canVote = true;
  int totalVotes = 0;
  int totalComments = 0;
  List<int> counters = [0, 0, 0, 0, 0];

  @override
  void initState() {
    checkVoted();
    setState(() {
      counters = widget.poll.poll.pollData["answers"]
          .map<int>((e) => int.parse(e["count"].toString()))
          .toList();
      totalComments = widget.poll.poll.numComments;
      print(totalComments);
      totalVotes = widget.poll.poll.votes;
    });
    super.initState();
  }

  checkVoted() async {
    bool hasVoted = await hasUserVoted(
        widget.poll.pollId, FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      canVote = hasVoted;
    });
  }

  Future<void> _onRefresh() async {
    // Simulate a delay while loading new data
    bool hasVoted = await hasUserVoted(
        widget.poll.pollId, FirebaseAuth.instance.currentUser!.uid);
    // Add some new data to the list
    setState(() {
      canVote = hasVoted;
    });

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
              pollFeedObj: widget.poll,
            ),
          ),
        );
        debugPrint("just left from poll");
        await checkVoted();
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
          child: Padding(
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
                          numBars: widget.poll.poll.pollData["answers"].length,
                          height: 35,
                          width: 38,
                          minHeight: 5,
                          counters: counters,
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
                        totalVotes.toString(),
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
