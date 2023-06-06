//  Created by Nicholas Eastmond on 9/26/22.

import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pollar/navigation/global_feed_page.dart';
import 'package:pollar/navigation/profile_page.dart';
import 'package:pollar/services/feeds/global_feed_provider.dart';
import 'package:pollar/services/feeds/main_feed_provider.dart';
import 'package:provider/provider.dart';
import '../login/login_page.dart';
import '../polls/create_poll_page.dart';
import '../polls_theme.dart';
import '../services/animations/main_animations.dart';
import '../services/auth.dart';

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
  bool displayAllPolls = false;
  int tabSelected = 0; // initially tab selected is poll feed
  bool refresh = false;
  late ConfettiController _controllerTopCenter;

  @override
  initState() {
    super.initState();
    _controllerTopCenter =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _controllerTopCenter.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GlobalFeedProvider>(
        create: (_) =>
            GlobalFeedProvider(), // Create a single instance of FeedProvider
        builder: (context, child) {
          return ChangeNotifierProvider<MainFeedProvider>(
              create: (_) =>
                  MainFeedProvider(), // Create a single instance of FeedProvider
              builder: (context, child) {
                return PollsTheme(
                  builder: (context, theme) => Scaffold(
                    key: _scaffoldKey,
                    endDrawer: MySidebar(
                      onClose: () {
                        Navigator.pop(context);
                      },
                    ),
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
                            tabSelected == 0
                                ? Icons.map_outlined
                                : tabSelected == 1
                                    ? (displayAllPolls == true
                                        ? Icons.location_on_outlined
                                        : Icons.location_off_outlined)
                                    : Icons.help_outline,
                            size: iconSize,
                          ),
                          onPressed: (() {
                            if (tabSelected == 0) {
                              MainFeedProvider feedProvider =
                                  Provider.of<MainFeedProvider>(context,
                                      listen: false);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CreateMapPage(
                                    feedProvider: feedProvider,
                                    fromFeed: true,
                                  ),
                                  settings: RouteSettings(
                                      arguments: runtimeType.toString()),
                                ),
                              );
                            }
                            if (tabSelected == 1) {
                              setState(() {
                                displayAllPolls = !displayAllPolls;
                              });
                            }
                          }),
                        ),
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: IconButton(
                            icon: Icon(
                              tabSelected == 0 || tabSelected == 1
                                  ? Icons.add_chart
                                  : Icons.settings_outlined,
                              size: iconSize,
                            ),
                            onPressed: (() {
                              if (tabSelected != 0 && tabSelected != 1) {
                                _scaffoldKey.currentState?.openEndDrawer();

                                return;
                              }
                              MainFeedProvider feedProvider =
                                  Provider.of<MainFeedProvider>(context,
                                      listen: false);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CreatePollPage(
                                    feedProvider: feedProvider,
                                    onPollCreated: () {
                                      print("playConfetti");
                                      _controllerTopCenter.play();
                                      print("confetti done");
                                    },
                                  ),
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
                    bottomNavigationBar: BottomNavigationBar(
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
                            Icons.language_outlined,
                            size: iconSize,
                          ),
                          label: 'Global Feed Page',
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
                    body: Stack(
                      children: [
                        IndexedStack(
                          index: tabSelected,
                          children: [
                            FeedPage(
                              feedProvider: Provider.of<MainFeedProvider>(
                                  context,
                                  listen: false),
                            ),
                            GlobalFeedPage(
                              filterGlobalOnly: !displayAllPolls,
                              globalFeedProvider:
                                  Provider.of<GlobalFeedProvider>(context,
                                      listen: false),
                            ), // This should be Global Feed
                            const ProfilePage(),
                          ],
                        ),
                        //TOP CENTER - shoot down
                        Align(
                          alignment: const Alignment(0.0, -0.65),
                          child: ConfettiWidget(
                            confettiController: _controllerTopCenter,
                            blastDirectionality: BlastDirectionality
                                .explosive, // don't specify a direction, blast randomly
                            shouldLoop:
                                false, // start again as soon as the animation is finished
                            colors: const [
                              Colors.green,
                              Colors.blue,
                              Colors.pink,
                              Colors.orange,
                              Colors.purple
                            ], // manually specify the colors to be used
                            numberOfParticles: 20,
                            emissionFrequency: 0,
                            gravity: .1,
                            createParticlePath:
                                drawStar, // define a custom shape/path.
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
        });
  }
}

class MySidebar extends StatelessWidget {
  const MySidebar({super.key, required this.onClose});
  void deleteAccountConfirmation(context) {
    showDialog(
        context: context,
        builder: (BuildContext c) {
          return AlertDialog(
              title: const Text('Deletion Confirmation'),
              content: const Text(
                'Are you sure you want to permanently delete your Pollar account?',
                textScaleFactor: 1,
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      var snackBar = const SnackBar(
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.green,
                        content: Text(
                          'Account deleted',
                          textAlign: TextAlign.center,
                        ),
                      );
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                          (route) => false);
                      PollarAuth.deleteUser();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                    child: const Text('Yes')),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('No'))
              ]);
        });
  }

  final VoidCallback onClose;
  @override
  Widget build(BuildContext context) {
    return PollsTheme(builder: (context, theme) {
      return Drawer(
        backgroundColor: theme.cardColor,
        width: MediaQuery.of(context).size.width * (2 / 3),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 135,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      theme.secondaryHeaderColor,
                      theme.primaryColor,
                    ],
                  ),
                ),
                child: const Text(
                  '',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    height: 1.5,
                    color: Colors.white,
                    fontSize: 15,
                    shadows: [
                      Shadow(
                        color: Color.fromARGB(50, 0, 0, 0),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text(
                'Reset Password',
                style: TextStyle(
                  height: 1.4,
                  color: theme.indicatorColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w300,
                ),
              ),
              onTap: () {
                PollarAuth.resetPassword();
                var passResetSnackBar = SnackBar(
                  duration: const Duration(seconds: 3),
                  backgroundColor: theme.secondaryHeaderColor,
                  content: const Text(
                    'Password reset link sent to email',
                    textAlign: TextAlign.center,
                  ),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(passResetSnackBar);
                }
                onClose();
              },
            ),
            const Divider(),
            ListTile(
              title: Text(
                'Sign Out',
                style: TextStyle(
                  height: 1.4,
                  color: theme.indicatorColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w300,
                ),
              ),
              onTap: () {
                PollarAuth.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false);
              },
            ),
            const Divider(),
            ListTile(
              title: Text(
                'Delete Account',
                style: TextStyle(
                  height: 1.4,
                  color: theme.indicatorColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w300,
                ),
              ),
              onTap: () {
                deleteAccountConfirmation(context);
                // Handle item 2 tapped
              },
            ),
            const Divider(),
            SizedBox(
              height: MediaQuery.of(context).size.height - 440,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Logged in as:\n${PollarAuth.getEmail()}',
                textAlign: TextAlign.start,
                style: TextStyle(
                    height: 1.5,
                    color: MediaQuery.of(context).platformBrightness ==
                            Brightness.light
                        ? Colors.black
                        : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w200),
              ),
            ),
          ],
        ),
      );
    });
  }
}
