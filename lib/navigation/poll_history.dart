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
      builder: (context, theme) => MaterialApp(
        home: DefaultTabController(
          length: 2, 
          child: Scaffold(
            appBar: AppBar(
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
              title: const Center(
                child: Padding(
                  padding: EdgeInsets.only(right: 50),
                  child: Icon(
                    Icons.bar_chart,
                    size: 32,
                  ),
                ),
              ),
              bottom: TabBar(
                indicatorColor: theme.indicatorColor,
                tabs: const [
                  Tab(text: 'My Polls'),
                  Tab(text: 'Voted'),
                ]
              )
            ),
            body: Container(
              color: theme.scaffoldBackgroundColor,
              child: TabBarView(
                children: [
                  // My Poll history page,
                  // Polls user voted on page
                ]
              ),
            ),
          )
        )
      ),
    );
  }
}