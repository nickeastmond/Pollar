//  Created by Nicholas Eastmond on 9/26/22.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pollar/login/login_page.dart';
import 'package:pollar/model/user/pollar_user_model.dart';
import 'package:pollar/navigation/profile_page.dart';
import 'package:pollar/services/auth.dart';
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
  static double iconSize = 30;
  static double elevation = 2.5;
  double? emojiBoxHeight = 0;
  String? profEmoji = PollarAuth.getDisplayName();

  int tabSelected = 0; // initially tab selected is poll feed

  @override
  initState() {
    super.initState();
    checkLocationEnabled(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget emojiOption(String emoji) {
    return TextButton(
      onPressed: () {
        profEmoji = emoji;
        setPollarUserEmoji(emoji);
        setState(() {
          emojiBoxHeight = 0;
        });
      },
      child: Text(
        emoji,
        textScaleFactor: 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PollsTheme(
      builder: (context, theme) => Scaffold(
        appBar: AppBar(
          //Top bar with app logo
          automaticallyImplyLeading: false,
          elevation: elevation,
          backgroundColor: theme.primaryColor,
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: IconButton(
              icon: Icon(
                Icons.map_outlined,
                size: iconSize,
              ),
              onPressed: (() {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateMapPage(),
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreatePollPage(),
                    ),
                  );
                }),
              ),
            ),
          ],
          title: const Icon(
            Icons.bar_chart,
            size: 35,
          ),
        ),
        bottomNavigationBar: Container(
          // decoration: const BoxDecoration(
          //   boxShadow: <BoxShadow>[
          //     BoxShadow(
          //       color: Colors.black38,
          //       blurRadius: 4,
          //       spreadRadius: 2,
          //     ),
          //   ],
          // ),
          child: BottomNavigationBar(
            //Navigation bar that contains feed, poll, and profile page icons
            elevation: 25,
            backgroundColor: theme.primaryColor,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedItemColor: theme.unselectedWidgetColor,
            unselectedItemColor: theme.unselectedWidgetColor.withAlpha(100),
            currentIndex: tabSelected,
            onTap: (int tab) => setState(() => tabSelected = tab),
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  //Icons.table_rows_outlined,
                  Icons.assessment_outlined,
                  size: iconSize,
                ),
                label: 'Feed Page',
              ),
              // BottomNavigationBarItem(
              //   icon: Icon(
              //     Icons.assessment_outlined,
              //     size: iconSize,
              //   ),
              //   label: 'Poll Page',
              // ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.person_outline,
                  size: iconSize,
                ),
                label: 'Profile Page',
              ),

              // TEMP
              BottomNavigationBarItem(
                icon: IconButton(
                    icon: const Icon(Icons.exit_to_app),
                    iconSize: iconSize,
                    onPressed: () async {
                                PollarAuth.signOut().then((_) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (context) => const LoginPage()),
                                  );
                                });
                              }),
                label: 'Temporary Sign Out Page',
              ),
            ],
          ),
        ),
        body: IndexedStack(
          index: tabSelected,
          //const [FeedPage(), ReceivePollPage(), ProfilePage()],
          //children: const [FeedPage(), ProfilePage()],
          children: [
            
            Container(
              color: theme.secondaryHeaderColor,
            ),

            // ProfilePage()
            const FeedPage(),
            Container(
              color: theme.primaryColor,
              alignment: Alignment.center,
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 40),
                        child: Column(
                          children: [
                            // emoji pfp
                            SizedBox(
                              height: 100,
                              child: 
                              //if no saved emoji:
                              Text(
                                '${profEmoji}',
                                textScaleFactor: 6,
                              ),
                            ),
                            const SizedBox(
                              height: 25
                            ),
                            // Change emoji functionality

                      
                            TextButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(Colors.black.withOpacity(0.2))
                              ),
                              child: const Text(
                                "Change Profile Emoji",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                )
                              ),
                              onPressed: () {
                                setState(() {
                                  if (emojiBoxHeight! > 0) {
                                    emojiBoxHeight = 0;
                                  } else {
                                    emojiBoxHeight = 100;
                                  }
                                });
                              },
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              height: emojiBoxHeight,
                              color: Colors.black.withOpacity(0.2),
                              padding: const EdgeInsets.symmetric(horizontal: 25),
                              child: Flex(
                                direction: Axis.horizontal,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  emojiOption(defaultEmoji),
                                  emojiOption('😂'),
                                  emojiOption('😍'),
                                ],
                              ),
                            ),
                          
                            const SizedBox(
                              height: 25
                            ),
                            // account details
                            Container(
                              child: Column(
                                children: [
                                  const Text(
                                    'Email:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                    ),
                                  ),
                                  Text(
                                    // futureToString(getPollarUserEmail()),
                                    '${PollarAuth.getEmail()}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 25
                                  ),
                                  // change email
                                  TextButton(
                                    style: ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(Colors.black.withOpacity(0.2)),
                                    ),
                                    child: const Text(
                                      "Change Email",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                      ),
                                    ),
                                    onPressed: () {
                                      // change email
                                    },
                                  ),
                                  const SizedBox(
                                    height: 25
                                  ),
                                  //change password button
                                  TextButton(
                                    style: ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(Colors.black.withOpacity(0.2)),
                                    ),
                                    child: const Text(
                                      "Change Password",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                      ),
                                    ),
                                    onPressed: () {
                                      // change pass
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 25
                            ),

                            // sign out button
                            TextButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(Colors.black.withOpacity(0.2)),
                              ),
                              child: const Text(
                                "Sign out",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                )
                              ),
                              onPressed: () async {
                                PollarAuth.signOut().then((_) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (context) => const LoginPage()),
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
