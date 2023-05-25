//  Created by Nicholas Eastmond on 9/26/22.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pollar/navigation/profile_page.dart';
import 'package:provider/provider.dart';
import '../model/Poll/database/delete_all.dart';
import '../model/user/database/delete_user_db.dart';
import '../polls/create_poll_page.dart';
import '../polls_theme.dart';
import '../services/location/location.dart';

import '../maps.dart';
import 'feed_page.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({
    super.key,
  });

  @override
  State<NavigationPage> createState() => NavigationPageState();
}

class NavigationPageState extends State<NavigationPage> {
  static double iconSize = 32;
  static double elevation = 2.5;
  int tabSelected = 0; // initially tab selected is poll feed
  bool refresh =  false;

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
    return ChangeNotifierProvider(
        create: (_) => FeedProvider()
          ..fetchInitial(100), // Create a single instance of FeedProvider
        builder: (context, child) {
          return PollsTheme(
            builder: (context, theme) => Scaffold(
              appBar: AppBar(
                //Top bar with app logo
                centerTitle: true,
                automaticallyImplyLeading: false,
                elevation: elevation,
                backgroundColor: theme.primaryColor,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.map_outlined,
                      size: iconSize,
                    ),
                    onPressed: (() {
                      FeedProvider feedProvider =
                          Provider.of<FeedProvider>(context, listen: false);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              CreateMapPage(feedProvider: feedProvider),
                        ),
                      );
                    }),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: IconButton(
                      icon: Icon(
                        Icons.add_chart,
                        size: iconSize,
                      ),
                      onPressed: (() {
                        FeedProvider feedProvider =
                            Provider.of<FeedProvider>(context, listen: false);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                CreatePollPage(feedProvider: feedProvider),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
                title: Icon(
                  Icons.bar_chart,
                  size: iconSize,
                ),
              ),
              bottomNavigationBar: Container(
                child: BottomNavigationBar(
                  //Navigation bar that contains feed, poll, and profile page icons
                  elevation: 25,
                  backgroundColor: theme.primaryColor,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  selectedItemColor: theme.unselectedWidgetColor,
                  unselectedItemColor:
                      theme.unselectedWidgetColor.withAlpha(100),
                  currentIndex: tabSelected,
                  onTap: (int tab) => setState(() => tabSelected = tab),
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.assessment_outlined,
                        size: iconSize,
                      ),
                      label: 'Feed Page',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.person_outline,
                        size: iconSize,
                      ),
                      label: 'Profile Page',
                    ),
                  ],
                ),
              ),
              body: IndexedStack(
                index: tabSelected,
                
                children: [
                  
                  FeedPage(
                    feedProvider: Provider.of<FeedProvider>(context, listen: false),
                  ),
                  const ProfilePage(),
                ],
              ),
            ),
          );
        });
  }
}
