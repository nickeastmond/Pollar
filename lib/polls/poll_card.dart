import 'package:flutter/material.dart';
import 'package:pollar/navigation/feed_page.dart';

import '../model/Poll/poll_model.dart';
import '../polls_theme.dart';
import '../user/main_profile_circle.dart';
import 'bar_graph.dart';
import 'expanded_poll_page.dart';

class PollCard extends StatelessWidget {
  const PollCard({
    Key? key,
    required this.poll,
  }) : super(key: key);
  final PollFeedObject poll;

  

  @override
  Widget build(BuildContext context) {
    

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ExpandedPollPage(
              pollFeedObj: poll,
            ),
          ),
        );
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
                        poll.poll.pollData["question"],
                        style: TextStyle(
                          height: 1.4,
                          color: theme.indicatorColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: BarGraph(
                          initalDisplayData: true,
                          numBars: 5,
                          height: 35,
                          width: 38,
                          minHeight: 5,
                          counters: [1, 2, 3, 2, 1],
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
                      padding: EdgeInsets.only(bottom: 4.5),
                      child: Text(
                        poll.poll.numComments.toString(),
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
                        poll.poll.votes.toString(),
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
                        pollText(poll.poll.timestamp),
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
          ? MapEntry(since.inHours, "hrs")
          : MapEntry(since.inDays, "days");
  //return "${pair.key} ${pair.value} | ~${poll.milesFrom(currentLocation)}mi";
  if (pair.key == 1) 
  {
    return "${pair.key} day ago";
  }
  return "${pair.key} ${pair.value} ago";
}
