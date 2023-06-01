import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pollar/polls_theme.dart';
import 'package:pollar/services/feeds/main_feed_provider.dart';

import '../model/Poll/database/delete_poll.dart';
import '../model/Report/report_model.dart';
import '../services/feeds/feed_provider.dart';

class DeleteReportMenu extends StatelessWidget {
  const DeleteReportMenu(
      {Key? key,
      required this.pollObj,
      required this.feedProvider,
      required this.callback,
      required this.counters})
      : super(key: key);
  final PollFeedObject pollObj;
  final FeedProvider feedProvider;
  final VoidCallback callback;
  final List<int> counters;
  @override
  Widget build(BuildContext context) {
    return PollsTheme(builder: (context, theme) {
      return Container(
        height: MediaQuery.of(context).size.height / 3,
        padding: const EdgeInsets.all(30.0),
        color: const Color.fromARGB(255, 233, 232, 232).withAlpha(0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Card(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(0))),
                color: theme.primaryColor,
                child: ListTile(
                  title: const Center(
                    child: Text(
                      "Delete",
                      style:
                          TextStyle(fontSize: 17.5, color: Colors.white),
                    ),
                  ),
                  onTap: () {
                    deleteWarning(context, feedProvider);
                  },
                ),
              ),
              Card(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(0))),
                color: theme.primaryColor,
                child: ListTile(
                  title: const Center(
                    child: Text(
                      "Report",
                      style:
                          TextStyle(fontSize: 17.5, color: Colors.white),
                    ),
                  ),
                  onTap: () {
                    reportWarning(context);
                  },
                ),
              ),
              Card(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(0))),
                color: theme.secondaryHeaderColor,
                child: ListTile(
                  title: const Center(
                    child: Text(
                      "Cancel",
                      style: TextStyle(fontSize: 17.5, color: Colors.white),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> reportWarning(BuildContext context) {
    return showCupertinoModalPopup<void>(
      context: context,
      barrierColor: Colors.grey.shade900.withOpacity(0.7),
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Report this Post?'),
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
               Map<String, dynamic> data = {};
              String id = FirebaseAuth.instance.currentUser!.uid;
              data["pollId"] = pollObj.pollId;
              String reportPollId = pollObj.poll.userId;
              bool selfReport = false;
              if (reportPollId == id){
                debugPrint("We need to tell user that they cant report their own poll");
                selfReport = true;
              }
              else
              {
                  data["timestamp"] = DateTime.now();
                  Report newReport = Report.fromData(id, data);
                  bool success = await createReport(newReport);
                  if (!success)
                  {
                    debugPrint("Error creating report");
                  }
              }
              
              callback();
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context, counters);
              var snackBar = SnackBar(
                  backgroundColor: PollsTheme.lightTheme.secondaryHeaderColor,
                  content: Text(
                    selfReport ? "Can't Report Own Post" : "Reporting Post",
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

    Future<void> deleteWarning(BuildContext context, FeedProvider feedProvider) {
    return showCupertinoModalPopup<void>(
      context: context,
      barrierColor: Colors.grey.shade900.withOpacity(0.7),
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Delete this Post?'),
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
              String userIdOfPoll = pollObj.poll.userId;
              bool canDelete = false;
              if (userIdOfPoll == id){
                debugPrint("We need to tell user that they cant report their own poll");
                canDelete = true;
                bool success = await deletePoll(pollObj.pollId);
                if (success)
                {
                  await feedProvider.fetchInitial(100);
                }

              }
              
              callback();
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context, counters);
              var snackBar = SnackBar(
                  backgroundColor: PollsTheme.lightTheme.secondaryHeaderColor,
                  content: Text(
                     canDelete ? "Deleted Post" : "Can't Delete this Post",
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
}
