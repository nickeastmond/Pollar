import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pollar/navigation/feed_page.dart';
import 'package:pollar/polls_theme.dart';

import '../model/Report/report_model.dart';

class DeleteReportMenu extends StatelessWidget {
  const DeleteReportMenu(
      {Key? key,
      required this.delete,
      required this.pollObj,
      required this.callback,
      required this.counters})
      : super(key: key);
  final PollFeedObject pollObj;
  final bool delete;
  final VoidCallback callback;
  final List<int> counters;
  @override
  Widget build(BuildContext context) {
    return PollsTheme(builder: (context, theme) {
      return Container(
        height: MediaQuery.of(context).size.height / 4,
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
                  title: Center(
                    child: Text(
                      delete ? "Delete" : "Report",
                      style:
                          const TextStyle(fontSize: 17.5, color: Colors.white),
                    ),
                  ),
                  onTap: () {
                    logOutWarning(context);
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

  Future<void> logOutWarning(BuildContext context) {
    return showCupertinoModalPopup<void>(
      context: context,
      barrierColor: Colors.grey.shade900.withOpacity(0.7),
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(delete ? 'Delete this Post?' : 'Report this Post?'),
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
              data["timestamp"] = DateTime.now();
              Report newReport = Report.fromData(id, data);
              bool success = await createReport(newReport);
              if (!success)
              {
                debugPrint("Error creating report");
              }
              callback();
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context, counters);
              var snackBar = SnackBar(
                  backgroundColor: PollsTheme.lightTheme.secondaryHeaderColor,
                  content: Text(
                    delete ? "Deleted Post" : "Reporting Post",
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
