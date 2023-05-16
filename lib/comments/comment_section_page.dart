import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pollar/comments/comment_card.dart';
import 'package:pollar/model/Comment/comment_model.dart';
import 'package:pollar/navigation/feed_page.dart';
import 'package:uuid/uuid.dart';

import '../model/Poll/poll_model.dart';
import '../polls_theme.dart';

class CommentSectionPage extends StatefulWidget {
  const CommentSectionPage(
    this.poll, {
    Key? key,
  }) : super(key: key);

  final PollFeedObject poll;

  @override
  State<CommentSectionPage> createState() => _CommentSectionPageState();
}

class _CommentSectionPageState extends State<CommentSectionPage> {
  final commentTextEditorController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      body: FutureBuilder<List<Comment>>(
                  future: getComments(widget.poll.pollId),
                  builder: (commentContext, commentSnapshot) {
         

        final List<Comment> comments = commentSnapshot.data ?? [];
        return SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height / 2),
                child: Column(
                  children: [
                    for (int i = 0; i < comments.length; i++)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CommentCard(
                          roundedTop: true,
                          comment:
                              comments[i].text),
                    ),
                    const SizedBox(
                      height: 115,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: PollsTheme(
                builder: (context, theme) {
                  return Container(
                    height: 110,
                    color: theme.scaffoldBackgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Stack(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 90,
                            child: TextField(
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              controller: commentTextEditorController,
                              minLines: 1,
                              maxLines: 10,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: InputDecoration(
                                fillColor:
                                    MediaQuery.of(context).platformBrightness ==
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
                                    borderRadius: BorderRadius.circular(20.0)),
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
                          Positioned(
                            right: 0,
                            bottom: 30,
                            child: GestureDetector(
                              onTap: (() async {
                                debugPrint("Creating comment");
                                // Creating a comment locally
                                Map<String, dynamic> data = {};
                                Uuid uuid = const Uuid();
                                String v4 = uuid.v4(); // -> '110ec58a-a0f2-4ac4-8393-c866d813b8d1'
                                data["uid"] = v4;
                                String id = FirebaseAuth.instance.currentUser!.uid;
                                data["pollId"] = widget.poll.pollId;
                                data["text"] = commentTextEditorController.text;
                                data["timestamp"] = DateTime.now();
                                Comment newComment = Comment.fromData(id, data);
                                bool success = await createComment(newComment);
                                if (!success)
                                {
                                  debugPrint("Error creating comment");
                                }
                              }),
                              child: Icon(
                                Icons.send,
                                size: 27.5,
                                color:
                                    MediaQuery.of(context).platformBrightness ==
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
            ),
          ],
        ),
      );}
      )
    );
  }
}
