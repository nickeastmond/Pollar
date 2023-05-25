import 'package:flutter/material.dart';
import '../polls_theme.dart';

class PollHistoryPage extends StatefulWidget {
  const PollHistoryPage({
    super.key,
  });

  @override
  State<PollHistoryPage> createState() => PollHistoryPageState();
}

class PollHistoryPageState extends State<PollHistoryPage> {
  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PollsTheme(
      builder: (context, theme) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          elevation: 2.5,
          backgroundColor: theme.primaryColor,
          leading: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 30.0,
              ),
            ),
          ),
          title: const Icon(
            Icons.bar_chart,
            size: 32,
          ),
        ),
      ),
    );
  }
}