//  Created by Nicholas Eastmond on 9/26/22.



import 'package:flutter/material.dart';
import 'package:pollar/login/login_page.dart';

import 'package:flutter/material.dart';
import '../polls_theme.dart';
import '../services/location.dart';


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


  @override
  Widget build(BuildContext context) {
    return PollsTheme(
      builder: (context, theme) => Scaffold(
        appBar: AppBar(
          //Top bar with app logo
          automaticallyImplyLeading: false,
          elevation: elevation,
          backgroundColor: theme.primaryColor,
          title: const Icon(
            Icons.bar_chart_rounded,
            size: 35,
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black38,
                blurRadius: 4,
                spreadRadius: 2,
              ),
            ],
          ),
          child: BottomNavigationBar(
            //Navigation bar that contains feed, poll, and profile page icons
            elevation: 25,
            backgroundColor: theme.primaryColor,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedItemColor: theme.unselectedWidgetColor.withAlpha(100),
            unselectedItemColor: theme.unselectedWidgetColor,
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
            ],
          ),
        ),
        body: IndexedStack(
          index: tabSelected,
          //const [FeedPage(), ReceivePollPage(), ProfilePage()],
          //children: const [FeedPage(), ProfilePage()],
          children: [
            
            Container(
              color: Colors.blue,
            ),

            // ProfilePage()
            Container(
              color: Colors.red,
              alignment: Alignment.center,
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                        child: Column(
                          children: [
                            // emoji pfp
                            SizedBox(
                              height: 100,
                              child: Image.asset(
                                'assets/sample_emoji.png',
                                alignment: Alignment.topCenter,
                              ),
                            ),
                            const SizedBox(
                              height: 25
                            ),

                            // Change emoji button
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
                                // bring up list of emojis to pick from
                              },
                            ),

                            // account details

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
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
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
