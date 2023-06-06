import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pollar/comments/comment_card.dart';
import 'package:pollar/model/Comment/comment_model.dart';
import 'package:pollar/model/constans.dart';
import 'package:pollar/model/user/pollar_user_model.dart';

import 'package:uuid/uuid.dart';

import '../model/Poll/poll_model.dart';
import '../polls_theme.dart';
import '../services/feeds/feed_provider.dart';

class CommentSectionPage extends StatefulWidget {
  const CommentSectionPage(
    this.poll,
    this.feedProvider, {
    Key? key,
  }) : super(key: key);

  final PollFeedObject poll;
  final FeedProvider feedProvider;

  @override
  State<CommentSectionPage> createState() => _CommentSectionPageState();
}

class _CommentSectionPageState extends State<CommentSectionPage> {
  final commentTextEditorController = TextEditingController();
  bool refresh = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height / 2),
                  child: FutureBuilder<List<CommentFeedObj>>(
                      future: getComments(widget.poll.pollId),
                      builder: (commentContext, commentSnapshot) {
                        final List<CommentFeedObj> comments =
                            commentSnapshot.data ?? [];
                        return Column(
                          children: [
                            for (int i = 0; i < comments.length; i++)
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0, top: 8.0),
                                child: CommentCard(
                                    pollObj: widget.poll,
                                    feedProvider: widget.feedProvider,
                                    roundedTop: i == 0, commentFeedObj: comments[i]),
                                    

                              ),
                            const SizedBox(
                              height: 150,
                            )
                          ],
                        );
                      }),
                ),
              ),
              Positioned(
                bottom: 0,
                child: PollsTheme(
                  builder: (context, theme) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      height: 110,
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 1,
                              spreadRadius: 0),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Stack(
                          children: [
                            FocusScope(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width - 90,
                                child: TextField(
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.done,
                                  controller: commentTextEditorController,
                                  minLines: 1,
                                  maxLines: 10,
                                  textAlignVertical: TextAlignVertical.top,
                                  decoration: InputDecoration(
                                    fillColor: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light
                                        ? Colors.grey.shade200
                                        : Colors.grey.shade900,
                                    hintStyle: TextStyle(
                                      color: MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.light
                                          ? Colors.black.withAlpha(75)
                                          : Colors.grey.shade800,
                                    ),
                                    hintText: "Add a Comment",
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0)),
                                    alignLabelWithHint: true,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.never,
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 16),
                                    filled: true,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 30,
                              child: GestureDetector(
                                onTap: (() async {
                                  debugPrint("Creating comment");
                                  // Creating a comment locally
                                  Map<String, dynamic> data = {};
                                  Uuid uuid = const Uuid();
                                  String v4 = uuid
                                      .v4(); // -> '110ec58a-a0f2-4ac4-8393-c866d813b8d1'
                                  data["uid"] = v4;
                                  String id =
                                      FirebaseAuth.instance.currentUser!.uid;
                                  data["pollId"] = widget.poll.pollId;
                                  if (commentTextEditorController.text.isNotEmpty)
                                  {
                                      data["text"] =
                                      commentTextEditorController.text;
                                  data["timestamp"] = DateTime.now();
                                  Comment newComment =
                                      Comment.fromData(id, data);
                                  bool success =
                                      await createComment(newComment);
                                  if (!success) {
                                    debugPrint("Error creating comment");
                                  }
                                  FocusScope.of(context).unfocus();
                                  await widget.feedProvider.fetchInitial(100);
                                  setState(() {
                                    refresh = !refresh;
                                    commentTextEditorController.text = "";
                                    addPoints(Constants.COMMENT_POINTS);
                                  });
                                  }
                                  
                                }),
                                child: Icon(
                                  Icons.send,
                                  size: 27.5,
                                  color: MediaQuery.of(context)
                                              .platformBrightness ==
                                          Brightness.light
                                      ? Colors.black.withAlpha(75)
                                      : Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ));
  }
}
