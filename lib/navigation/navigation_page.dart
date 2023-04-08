//  Created by Nicholas Eastmond on 9/26/22.



import 'package:flutter/material.dart';
import 'package:pollar/login/login_page.dart';

import '../polls/create_poll_page.dart';
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
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: IconButton(
              icon: Icon(
                Icons.map_outlined,
                size: iconSize,
              ),
              onPressed: (() {}),
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
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
                  }
                  ),
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
            Container(
              color: theme.primaryColor,
            )
          ],
        ),
      ),
    );
  }
}
