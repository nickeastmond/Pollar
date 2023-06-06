import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pollar/polls_theme.dart';

import '../model/Comment/comment_model.dart';
import '../polls/poll_card.dart';
import '../services/feeds/feed_provider.dart';
import '../user/main_profile_circle.dart';

class CommentCard extends StatefulWidget {
  const CommentCard({
    required this.commentFeedObj,
    required this.roundedTop,
    required this.pollObj,
    required this.feedProvider,
    Key? key,
  }) : super(key: key);
  final CommentFeedObj commentFeedObj;
  final bool roundedTop;
  final PollFeedObject pollObj;
  final FeedProvider feedProvider;

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> deleteCommentWarning(BuildContext context, FeedProvider feedProvider) {
    return showCupertinoModalPopup<void>(
      context: context,
      barrierColor: Colors.grey.shade900.withOpacity(0.7),
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Delete this Comment?'),
        content: const Text('Are you sure?'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              String id = FirebaseAuth.instance.currentUser!.uid;
              bool canDelete = false;
              if (widget.commentFeedObj.comment.userId == id) {
                canDelete = true;
                bool success = await deleteComment(widget.commentFeedObj.commentId);
                              Navigator.pop(context);

               
              }
              Navigator.pop(context);

              var snackBar = SnackBar(
                  backgroundColor: PollsTheme.lightTheme.secondaryHeaderColor,
                  content: Text(
                    canDelete ? "Deleted Comment" : "Can't Delete this Comment",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 17.5, color: Colors.white),
                  ));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
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
                      emoji: widget.pollObj.pollarUser.emoji,
                      fillColor: widget.pollObj.pollarUser.emojiBgColor,
                      borderColor: MediaQuery.of(context).platformBrightness == Brightness.light? Colors.grey.shade200: Colors.grey.shade800,
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
                      widget.commentFeedObj.comment.text,
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
                    pollText(widget.commentFeedObj.comment.timestamp),
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
                        onTap: ()  {
                          deleteCommentWarning(context,widget.feedProvider).then((_)=>getComments(widget.pollObj.pollId));
                         
                        },
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

