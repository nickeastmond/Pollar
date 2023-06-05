import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:pollar/model/constans.dart';
import 'package:pollar/model/user/pollar_user_model.dart';
import 'package:pollar/polls/delete_report_menu.dart';
import 'package:pollar/services/feeds/main_feed_provider.dart';
import 'package:flutter/material.dart';
import 'package:pollar/model/Poll/poll_model.dart';
import 'package:pollar/polls/bar_graph.dart';
import '../model/Poll/database/voting.dart';
import '../model/Position/position_adapter.dart';
import '../polls_theme.dart';
import '../services/feeds/feed_provider.dart';
import '../user/main_profile_circle.dart';
import '../comments/comment_section_page.dart';

class ExpandedPollPage extends StatefulWidget {
  const ExpandedPollPage(
      {super.key, required this.pollFeedObj, required this.feedProvider});
  final PollFeedObject pollFeedObj;
  final FeedProvider feedProvider;
  // Output: [5, 2, 3]

  @override
  State<ExpandedPollPage> createState() => ExpandedPollPageState();
}

class ExpandedPollPageState extends State<ExpandedPollPage> {
  ScrollController scrollController = ScrollController();

  bool displayResults = false;
  bool canVote = true;
  bool outOfBounds = false;
  int vote = -1;
  List<int> counters = [0, 0, 0, 0, 0];

  @override
  void initState() {
    eligibleVote().then((status) {
      setState(() {
        counters = widget.pollFeedObj.poll.pollData["answers"]
            .map<int>((e) => int.parse(e["count"].toString()))
            .toList();
      });
      if (status == false) {
        setState(() {
          List<Map<String, dynamic>> answers = [];
          for (int i = 0;
              i < widget.pollFeedObj.poll.pollData["answers"].length;
              i++) {
            String answer =
                widget.pollFeedObj.poll.pollData["answers"][i]["text"];

            answers.add({"text": answer, "count": counters[i]});
          }
          widget.pollFeedObj.poll.pollData["answers"] = answers;
        });
      }
    });

    super.initState();
  }

  Future<bool> eligibleVote() async {
    bool status = await pollStatus(FirebaseAuth.instance.currentUser!.uid,
        widget.pollFeedObj.pollId, widget.pollFeedObj.poll);
    bool withinRange = await inRange();
    setState(() {
      outOfBounds = !withinRange;
      canVote = status;
    });
    return status;
  }

  Future<bool> inRange() async {
    final pollLocation = Position(
        latitude: widget.pollFeedObj.poll.locationData.latitude,
        longitude: widget.pollFeedObj.poll.locationData.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0);

    bool? locationGranted =
        await PositionAdapter.getLocationStatus("locationGranted");
    Position? physicalLocation =
        await PositionAdapter.getFromSharedPreferences("physicalLocation");
    final bool inRange = await geoPointsDistance(
        physicalLocation!, pollLocation, widget.pollFeedObj.poll.radius);

    if (locationGranted == true && inRange) {
      debugPrint("inRange");
      return true;
    } else {
      return false;
    }
  }

  void showLoadingScreen(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Stack(
          children: <Widget>[
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
                fillColor: widget.pollFeedObj.pollarUser.emojiBgColor,
                size: 31,
                width: 2.5,
                emojiSize: 18,
                emoji: widget.pollFeedObj.pollarUser.emoji,
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
                          child: CommentSectionPage(
                              widget.pollFeedObj, widget.feedProvider));
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
                onTap: () {
                  showModalBottomSheet<void>(
                    backgroundColor: theme.scaffoldBackgroundColor,
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(25.0)),
                    ),
                    elevation: 2,
                    builder: (BuildContext context) {
                      return DeleteReportMenu(
                        // counters is the return list to update feed once user has voted. just keeping this to avoid errors because feed is expecting them
                        counters: counters,
                        pollObj: widget.pollFeedObj,
                        feedProvider: widget.feedProvider,
                        callback: () {
                          debugPrint("Poll has been reported");
                        },
                      );
                    },
                  );
                },
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
                            if (outOfBounds) {
                              var snackBar = const SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(
                                    "Cannot vote: This Poll Creator restricted voting rights to a radius that does not include your location",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 17.5, color: Colors.white),
                                  ));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                              return;
                            }
                            if (!canVote) {
                              var snackBar = const SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(
                                    "Cannot vote on same poll twice",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 17.5, color: Colors.white),
                                  ));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                              return;
                            }
                            showLoadingScreen(context);
                            bool success = await pollInteraction(
                                i,
                                FirebaseAuth.instance.currentUser!.uid,
                                widget.pollFeedObj.pollId,
                                widget.pollFeedObj.poll);
                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);

                            if (success) {
                              setState(() {
                                vote = i;
                                canVote = false;
                                counters[i]++;
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
                                const Color(0xFFFF5F6D),
                                const Color(0xFF01B9CC),
                                const Color(0xFFFFC371),
                                const Color.fromARGB(255, 173, 129, 231),
                                const Color.fromARGB(255, 88, 196, 136),
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
