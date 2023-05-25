import 'dart:ffi';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pollar/model/constans.dart';
import 'package:pollar/navigation/feed_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pollar/model/Position/position_adapter.dart';
import 'package:pollar/model/user/pollar_user_model.dart';

import '../model/Poll/database/add_poll_firestore.dart';
import '../model/Poll/poll_model.dart';
import '../polls_theme.dart';
import 'bar_graph.dart';

class CreatePollPage extends StatefulWidget {
  const CreatePollPage({Key? key, required this.feedProvider})
      : super(key: key);
  final FeedProvider feedProvider;

  @override
  State<CreatePollPage> createState() => CreatePollPageState();
}

class CreatePollPageState extends State<CreatePollPage> {
  TextEditingController pollQuestionController = TextEditingController();
  ScrollController scrollController = ScrollController();
  List<TextEditingController> pollChoices = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];
  int numBars = 5;

  @override
  Widget build(BuildContext context) {
    return PollsTheme(builder: (context, theme) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          title: const Text("New Poll"),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 17.5),
                child: GestureDetector(
                  onTap: () async {
                    try {
                      
                      // Cant post poll if location isnt granted
                      bool? locationGranted = await PositionAdapter.getLocationStatus("locationGranted");
                      if ( locationGranted== false && context.mounted)
                      {
                        debugPrint("CAnnot Post Poll - You need to enable your location");
                        Navigator.pop(context);
                        return;
                      }
                      Position? physicalLocation = await PositionAdapter.getFromSharedPreferences("physicalLocation");
                      Map<String, dynamic> data = {};

                  
                      Position? cur =
                          await PositionAdapter.getFromSharedPreferences(
                              "physicalLocation");

                      if (pollQuestionController.text.isEmpty) {
                        debugPrint("Please don't leave the question empty");
                        throw Exception(
                            "Tried to submit without filling out the question");
                      }

                      data.addAll({
                        "locationData": GeoPoint(cur!.latitude, cur.longitude),
                        "pollData": {
                          "question": pollQuestionController.text,
                          "answers": List<Map<String, int>>
                        }
                      });

                      List<Map<String, dynamic>> answers = [];
                      for (int i = 0; i < numBars; i++) {
                        String answer = pollChoices[i].text;
                        if (answer.isEmpty) {
                          debugPrint("Please don't leave any answers empty");
                          throw Exception(
                              "Tried to submit without filling out answers");
                        }
                        answers.add({"text": answer, "count": 0});
                      }
                      data["pollData"]["answers"] = answers;
                      String uid = FirebaseAuth.instance.currentUser!.uid;
                      data["timestamp"] = DateTime.now();
                      print(data["locationData"]);
                      Poll p = Poll.fromData(uid, data);
                      bool success = await addPollToFirestore(p);
                      final prefs = await SharedPreferences.getInstance();
                      await widget.feedProvider.fetchInitial(100);
                      if (context.mounted && success) {
                        Navigator.pop(context);
                        prefs.setInt('points',
                            sprefPoints + Constants.CREATE_POLL_POINTS);
                        sprefPoints = prefs.getInt('points')!;
                        points = sprefPoints;
                        addPoints(Constants.CREATE_POLL_POINTS);
                      }
                    } catch (e) {
                      debugPrint(e.toString());
                    }
                    //Poll newPoll = Poll.fromData(PollarAuth.getUid()!,data );
                  },
                  child: const Icon(
                    Icons.done_rounded,
                    size: 30.0,
                  ),
                )),
          ],
        ),
        body: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width - 32,
                child: TextField(
                  style: TextStyle(
                    fontSize: 17.5,
                    color: MediaQuery.of(context).platformBrightness ==
                            Brightness.light
                        ? Colors.black
                        : Colors.white,
                  ),
                  controller: pollQuestionController,
                  textInputAction: TextInputAction.done,
                  //keyboardType: TextInputType.name,
                  onChanged: (s) {},
                  minLines: 1,
                  maxLines: 2,
                  //maxLength: 60,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                    floatingLabelStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                    fillColor: MediaQuery.of(context).platformBrightness ==
                            Brightness.light
                        ? Colors.white
                        : Colors.black,
                    labelText: "Poll Question",
                    labelStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Colors.black
                          : Colors.white,
                    ),
                    //hintText:,
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    focusColor: Colors.white,
                    suffixIcon: Icon(
                      Icons.edit_outlined,
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Colors.black
                          : Colors.white,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.light
                              ? Colors.grey.shade900
                              : Colors.white,
                          width: 0.33),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 0.33),
                    ),
                    border: const UnderlineInputBorder(),
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
                    numBars: numBars,
                    height: MediaQuery.of(context).size.width - 120,
                    width: MediaQuery.of(context).size.width - 120,
                    spacing: 3,
                    minHeight: 15,
                    counters: const [27, 52, 70, 40, 23],
                    circleBorder: 0,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                          color: const Color.fromARGB(48, 0, 0, 0),
                          blurRadius: 10,
                          offset: Offset.fromDirection(pi / 2, 2))
                    ]),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (numBars > 2) {
                            setState(() => numBars--);
                          }
                          scrollController.animateTo(
                            numBars > 2
                                ? scrollController.position.maxScrollExtent -
                                    100
                                : 0,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.fastOutSlowIn,
                          );
                        },
                        child: Container(
                          height: 35,
                          width: 35,
                          // padding: EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset.fromDirection(pi / 2, 2))
                              ],
                              shape: BoxShape.circle,
                              color: Colors.grey.shade600),
                          child: const Icon(
                            Icons.remove,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (numBars < 5) {
                            setState(() => numBars++);
                          }
                          scrollController.animateTo(
                            scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.fastOutSlowIn,
                          );
                        },
                        child: Container(
                          height: 35,
                          width: 35,
                          // padding: EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset.fromDirection(pi / 2, 2))
                              ],
                              shape: BoxShape.circle,
                              color: Colors.grey.shade600),
                          child: const Icon(
                            Icons.add,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  Color(0xFFFF5F6D),
                  Color(0xFF01B9CC),
                  Color(0xFFFFC371),
                  Color.fromARGB(255, 173, 129, 231),
                  Color.fromARGB(255, 88, 196, 136),
                ]
                    .sublist(0, numBars)
                    .asMap()
                    .entries
                    .map(
                      (e) => SizedBox(
                        height: 100,
                        child: PollChoiceWidget(
                          controller: pollChoices[e.key],
                          color: e.value,
                          index: e.key,
                          visible: e.key < numBars,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(
                height: 100,
              )
            ],
          ),
        ),
      );
    });
  }
}

class PollChoiceWidget extends StatelessWidget {
  const PollChoiceWidget({
    Key? key,
    required this.controller,
    required this.index,
    required this.visible,
    required this.color,
  }) : super(key: key);

  final TextEditingController controller;
  final int index;
  final bool visible;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: visible ? 100 : 0,
        decoration: BoxDecoration(
          color: color,
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
              style: const TextStyle(fontSize: 17.5, color: Colors.white),
              textInputAction: TextInputAction.done,
              controller: controller,
              minLines: 1,
              maxLines: 10,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintStyle: TextStyle(color: Colors.black.withAlpha(85)),
                hintText: "Enter Poll Choice ${index + 1}",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                alignLabelWithHint: true,
                floatingLabelBehavior: FloatingLabelBehavior.never,
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                filled: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
