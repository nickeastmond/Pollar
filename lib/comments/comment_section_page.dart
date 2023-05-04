import 'package:flutter/material.dart';
import 'package:pollar/comments/comment_card.dart';

import '../model/Poll/poll_model.dart';
import '../polls_theme.dart';

class CommentSectionPage extends StatefulWidget {
  const CommentSectionPage(
    this.poll, {
    Key? key,
  }) : super(key: key);

  final Poll poll;

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
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height / 2),
                child: Column(
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CommentCard(
                          roundedTop: true,
                          comment:
                              'this is the UI for the comment section and the comment cards for now'),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8, right: 8, bottom: 8.0),
                      child: CommentCard(
                          roundedTop: false, comment: 'Short comment'),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8, right: 8, bottom: 8.0),
                      child: CommentCard(
                          roundedTop: false,
                          comment:
                              'This is an example of a medium sized comment'),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8, right: 8, bottom: 8.0),
                      child: CommentCard(
                          roundedTop: false,
                          comment:
                              'Now this will be a long comment. I will use the rest of this comment to tell you that I hope you are having an amazing week and you are all incredibly cool software developers'),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8, right: 8, bottom: 8.0),
                      child: CommentCard(
                          roundedTop: false,
                          comment:
                              'this is the UI for the comment section and the comment cards for now'),
                    ),
                    SizedBox(
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
                              onTap: (() async {}),
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
      ),
    );
  }
}
