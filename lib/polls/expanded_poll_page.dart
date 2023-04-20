import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pollar/navigation/feed_page.dart';
import 'package:pollar/polls/bar_graph.dart';
import '../polls_theme.dart';
import '../user/main_profile_circle.dart';

class ExpandedPollPage extends StatefulWidget {
  ExpandedPollPage({
    super.key,
    required this.pollFeedObj,
  });
  final PollFeedObject pollFeedObj;

  @override
  State<ExpandedPollPage> createState() => ExpandedPollPageState();
}

class ExpandedPollPageState extends State<ExpandedPollPage> {
  ScrollController scrollController = ScrollController();

  bool displayResults = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PollsTheme(builder: (context, theme) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          leading: const Padding(
            padding: EdgeInsets.only(left: 20),
            child: BackButton(
              color: Colors.white,
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
                onTap: () {},
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
        body: SingleChildScrollView(
          controller: ScrollController(),
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
                    numBars: 5,
                    initalDisplayData: false,
                    height: MediaQuery.of(context).size.width - 120,
                    width: MediaQuery.of(context).size.width - 120,
                    spacing: 3,
                    minHeight: 15,
                    counters: const [27, 52, 70, 40, 23],
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
                  for (int i = 0; i < widget.pollFeedObj.poll.pollData["answers"].length; i++)
                    GestureDetector(
                      onTap: () => {},
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
                                  text: widget.pollFeedObj.poll.pollData["answers"][i]),
                              style: const TextStyle(
                                  fontSize: 17.5, color: Colors.white),
                              textInputAction: TextInputAction.done,
                              minLines: 1,
                              maxLines: 10,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none),
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
      );
    });
  }
}
