import 'package:flutter/material.dart';
import 'package:pollar/polls_theme.dart';

import '../user/main_profile_circle.dart';

class CommentCard extends StatefulWidget {
  const CommentCard({
    required this.comment,
    required this.roundedTop,
    Key? key,
  }) : super(key: key);
  final String comment;
  final bool roundedTop;

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PollsTheme(builder: (context, theme) {
      return Container(
        decoration: BoxDecoration(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? theme.primaryColor
              : theme.cardColor,
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 0),
          ],
          borderRadius: widget.roundedTop
              ? const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                )
              : BorderRadius.circular(0),
          //borderRadius: BorderRadius.circular(20)
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: MainProfileCircleWidget(
                      emoji: '😄',
                      fillColor: Colors.orange,
                      borderColor: Colors.grey.shade200,
                      size: 35,
                      width: 2.5,
                      emojiSize: 17.5,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 100,
                    child: Text(
                      widget.comment,
                      style: TextStyle(
                        height: 1.4,
                        color: theme.indicatorColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Spacer()
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 65,
                  ),
                  Text(
                    "24 min ago",
                    style: TextStyle(
                      height: 1.4,
                      color: theme.indicatorColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const Spacer(),
                  PollsTheme(builder: (context, theme) {
                    return GestureDetector(
                        onTap: () {},
                        child: Icon(
                          Icons.more_horiz,
                          size: 23,
                          color: theme.indicatorColor,
                        ));
                  }),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              )
            ],
          ),
        ),
      );
    });
  }
}
