import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pollar/model/constans.dart';
import 'package:pollar/model/user/pollar_user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:pollar/model/Poll/poll_model.dart';
import 'package:pollar/navigation/feed_page.dart';
import 'package:pollar/polls/bar_graph.dart';
import '../model/Poll/database/voting.dart';
import '../polls_theme.dart';
import '../user/main_profile_circle.dart';
import '../comments/comment_section_page.dart';

class ExpandedPollPage extends StatefulWidget {
  ExpandedPollPage({
    super.key,
    required this.pollFeedObj,
  });
  final PollFeedObject pollFeedObj;
  // Output: [5, 2, 3]

  @override
  State<ExpandedPollPage> createState() => ExpandedPollPageState();
}

class ExpandedPollPageState extends State<ExpandedPollPage> {
  ScrollController scrollController = ScrollController();

  bool displayResults = false;
  bool canVote = true;
  int vote = -1;
  List<int> counters = [0, 0, 0, 0, 0];

  @override
  void initState() {
    checkVoted();
    setState(() {
      counters = widget.pollFeedObj.poll.pollData["answers"]
          .map<int>((e) => int.parse(e["count"].toString()))
          .toList();
    });

    super.initState();
  }

  checkVoted() async {
    bool hasVoted = await hasUserVoted(
        widget.pollFeedObj.pollId, FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      canVote = hasVoted;
    });
  }

  void showLoadingScreen(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Stack(
          children: const <Widget>[
            ModalBarrier(
              color: Color.fromARGB(0, 0, 0, 0),
              dismissible: false,
            ),
            Center(
              child: CircularProgressIndicator(
                color: Colors.teal,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onRefresh() async {
    // Simulate a delay while loading new data
    bool hasVoted = await hasUserVoted(
        widget.pollFeedObj.pollId, FirebaseAuth.instance.currentUser!.uid);

    // Add some new data to the list
    setState(() {
      canVote = hasVoted;
    });

    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance
            .collection('Poll')
            .doc(widget.pollFeedObj.pollId)
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
    return PollsTheme(builder: (context, theme) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context, counters);
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 30.0,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.5),
              child: MainProfileCircleWidget(
                fillColor: Colors.orange,
                size: 31,
                width: 2.5,
                emojiSize: 17.5,
                emoji: "😄",
                borderColor: Colors.grey.shade200,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 17),
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet<void>(
                    backgroundColor: theme.scaffoldBackgroundColor,
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(25.0)),
                    ),
                    elevation: 0,
                    builder: (BuildContext context) {
                      return ClipRRect(
                          borderRadius: BorderRadius.circular(30.0),
                          child: CommentSectionPage(widget.pollFeedObj.poll));
                    },
                  );
                },
                child: const Icon(
                  Icons.message_outlined,
                  color: Colors.white,
                  size: 30.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {},
                child: const Icon(
                  Icons.report_outlined,
                  size: 34.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          elevation: 2,
          backgroundColor: theme.primaryColor,
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            controller: ScrollController(),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: MediaQuery.of(context).size.height),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: Text(
                        widget.pollFeedObj.poll.pollData["question"],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.light
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    color: theme.scaffoldBackgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24.0,
                      ),
                      child: BarGraph(
                        numBars:
                            widget.pollFeedObj.poll.pollData["answers"].length,
                        initalDisplayData: !canVote,
                        height: MediaQuery.of(context).size.width - 120,
                        width: MediaQuery.of(context).size.width - 120,
                        spacing: 3,
                        minHeight: 15,
                        counters: counters,
                        circleBorder: 0,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        height: 16,
                        decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            boxShadow: [
                              BoxShadow(
                                  color: const Color.fromARGB(48, 0, 0, 0),
                                  blurRadius: 10,
                                  offset: Offset.fromDirection(pi / 2, 2))
                            ]),
                      ),
                      for (int i = 0;
                          i <
                              widget
                                  .pollFeedObj.poll.pollData["answers"].length;
                          i++)
                        GestureDetector(
                          onTap: () async {
                            if (!canVote) {
                              return;
                            }
                            showLoadingScreen(context);
                            bool success = await pollInteraction(
                                i,
                                FirebaseAuth.instance.currentUser!.uid,
                                widget.pollFeedObj.pollId);
                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);
                            if (success) {
                              final prefs = await SharedPreferences.getInstance();
                              setState(() {
                                vote = i;
                                canVote = false;
                                counters[i]++;
                                prefs.setInt('points', sprefPoints + Constants.VOTE_POINTS); 
                                sprefPoints = prefs.getInt('points')!;
                                points = sprefPoints;
                                addPoints(Constants.VOTE_POINTS);

                                List<Map<String, dynamic>> answers = [];
                                for (int i = 0;
                                    i <
                                        widget.pollFeedObj.poll
                                            .pollData["answers"].length;
                                    i++) {
                                  String answer = widget.pollFeedObj.poll
                                      .pollData["answers"][i]["text"];

                                  answers.add(
                                      {"text": answer, "count": counters[i]});
                                }
                                widget.pollFeedObj.poll.pollData["answers"] =
                                    answers;
                              });
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            height: 100,
                            decoration: BoxDecoration(
                              color: [
                                const Color.fromARGB(255, 243, 92, 81),
                                const Color.fromARGB(255, 96, 142, 240),
                                const Color.fromARGB(255, 248, 182, 82),
                                Colors.teal,
                                const Color.fromARGB(255, 159, 121, 226),
                              ][i % 5],
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 10,
                                    offset: Offset.fromDirection(pi / 2, 2))
                              ],
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: TextField(
                                  enabled: false,
                                  readOnly: true,
                                  controller: TextEditingController(
                                      text: widget.pollFeedObj.poll
                                          .pollData["answers"][i]["text"]),
                                  style: const TextStyle(
                                      fontSize: 17.5, color: Colors.white),
                                  textInputAction: TextInputAction.done,
                                  minLines: 1,
                                  maxLines: 10,
                                  textAlignVertical: TextAlignVertical.top,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        width: 2,
                                        style: vote == i
                                            ? BorderStyle.solid
                                            : BorderStyle.none,
                                        color: Colors.white,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 16),
                                    filled: true,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                  const SizedBox(
                    height: 100,
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
