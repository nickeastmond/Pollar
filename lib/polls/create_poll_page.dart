// ignore_for_file: invalid_use_of_protected_member

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pollar/model/constans.dart';
import 'package:pollar/services/feeds/main_feed_provider.dart';
import 'package:pollar/model/Position/position_adapter.dart';
import 'package:pollar/model/user/pollar_user_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../maps.dart';
import '../model/Poll/database/add_poll_firestore.dart';
import '../model/Poll/poll_model.dart';
import '../polls_theme.dart';
import 'bar_graph.dart';

class CreatePollPage extends StatefulWidget {
  const CreatePollPage({Key? key, required this.feedProvider})
      : super(key: key);
  final MainFeedProvider feedProvider;

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

  double _sliderValue = 0.0;

  void showLoadingScreen(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (
        BuildContext context,
      ) {
        return PollsTheme(builder: (context, theme) {
          return Stack(
            children: <Widget>[
              const ModalBarrier(
                color: Color.fromARGB(0, 0, 0, 0),
                dismissible: false,
              ),
              Center(
                child: CircularProgressIndicator(
                  color: theme.secondaryHeaderColor,
                ),
              ),
            ],
          );
        });
      },
    );
  }

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
                      if (pollQuestionController.text.isEmpty) {
                        debugPrint("Please don't leave the question empty");

                        throw Exception(
                            "Tried to submit without filling out the question");
                      }

                      for (int i = 0; i < numBars; i++) {
                        String answer = pollChoices[i].text;
                        if (answer.isEmpty) {
                          debugPrint("Please don't leave any answers empty");

                          throw Exception(
                              "Tried to submit without filling out answers");
                        }
                      }

                      //Lets now fetch location and radius with map
                      // MainFeedProvider feedProvider =
                      //     Provider.of<MainFeedProvider>(context, listen: false);

                      bool successMap = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CreateMapPage(
                            feedProvider: widget.feedProvider,
                            fromFeed: false,
                          ),
                        ),
                      );

                      if (!successMap) {
                        return;
                      }
                      showLoadingScreen(context);

                      Map<String, dynamic> data = {};
                      Position? cur =
                          await PositionAdapter.getFromSharedPreferences(
                              "virtualLocation");
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      _sliderValue = prefs.getDouble('Radius') ?? 0;

                      //We are done with location stuff, lets upload this info

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
                      data["radius"] = _sliderValue;
                      print(data["locationData"]);
                      Poll p = Poll.fromData(uid, data);
                      bool success = await addPollToFirestore(p);
                      if (context.mounted && success) {
                        await widget.feedProvider.fetchInitial(100);
                        addPoints(Constants.CREATE_POLL_POINTS);
                        Navigator.pop(context);
                        Navigator.pop(context);
                        //This seemed to work not having the UI in feed have a seizure
                        // ignore: invalid_use_of_visible_for_testing_member
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
              // const Padding(
              //   padding: EdgeInsets.symmetric(vertical: 16.0),
              //   child: Text(
              //     'Select a Radius',
              //     style: TextStyle(
              //       color: Colors.white,
              //       fontSize: 17.5,
              //     ),
              //   ),
              // ),
              // SizedBox(
              //   width: 200,
              //   child: SliderTheme(
              //     data: SliderTheme.of(context).copyWith(
              //       thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
              //       overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
              //       activeTrackColor: Colors.blue,
              //       inactiveTrackColor: Colors.grey,
              //       thumbColor: Colors.blue,
              //       overlayColor: Colors.blue.withOpacity(0.2),
              //     ),
              //     child: Slider(
              //       value: _sliderValue,
              //       min: 0.0,
              //       max: 20.0,
              //       onChanged: (newValue) {
              //         setState(() {
              //           _sliderValue = newValue;
              //         });
              //       },
              //       label: _sliderValue == 0.0
              //           ? 'Global'
              //           : "Poll Radius: ${_sliderValue.toStringAsFixed(1)}",
              //       divisions: 10,
              //     ),
              //   ),
              // ),
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
