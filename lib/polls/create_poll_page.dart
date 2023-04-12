import 'dart:math';

import 'package:flutter/material.dart';

import '../polls_theme.dart';
import 'bar_graph.dart';

class CreatePollPage extends StatefulWidget {
  const CreatePollPage({super.key});

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
                  onTap: () {},
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
                  const Color.fromARGB(255, 243, 92, 81),
                  const Color.fromARGB(255, 96, 142, 240),
                  const Color.fromARGB(255, 248, 182, 82),
                  Colors.teal,
                  const Color.fromARGB(255, 159, 121, 226),
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
                color: Color.fromARGB(48, 0, 0, 0),
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