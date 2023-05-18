import 'package:flutter/material.dart';
import 'package:pollar/services/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pollar/model/user/pollar_user_model.dart';
import 'package:pollar/login/login_page.dart';
import '../polls_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userEmoji = defaultEmoji;
  String sprefEmoji = 'null';
  List<dynamic> unlockedAssets = [];
  String dropdownState = '▲';
  double? emojiBoxHeight = 0;
  bool unverifiedTextVisibility = true;
  bool resetPassSent = false;

  @override
  initState() {
    updateMyEmoji('');
    updatePoints(0);
    fetchAssets();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetchAssets() async {
    List<dynamic> temp = await getUnlockedAssets();

    setState(() {
      unlockedAssets = temp;
    });
  }

  void updateMyEmoji(String emoji) async {
    final prefs = await SharedPreferences.getInstance();
    sprefEmoji = prefs.getString('emoji')!;
    print('spref emoji: $sprefEmoji');
    // new user
    if (sprefEmoji == 'null') {
      prefs.setString('emoji', defaultEmoji);
    // existing user
    } else if (emoji != ''){
      setEmoji(emoji);
      prefs.setString('emoji', emoji);
    }
    setState(() {
      sprefEmoji = prefs.getString('emoji')!;
      userEmoji = sprefEmoji;
    });
  } 

  void updatePoints(int num) async {
    final prefs = await SharedPreferences.getInstance();
    sprefPoints = prefs.getInt('points')!;
    // new user
    if (sprefPoints == -1) {
      prefs.setInt('points', 0);
    // existing user
    } else if (num > 0) {
      addPoints(num);
      prefs.setInt('points', sprefPoints + num);
    }
    setState(() {
      sprefPoints = prefs.getInt('points')!;
      points = sprefPoints;
    });
  } 

  int setStateFromAnotherPagePoints() {
    updatePoints(0);
    return points;
  }

  String setStateFromThisPageEmoji() {
    updateMyEmoji('');
    return userEmoji;
  }

  void confirmationAndPurchase(String emoji) { 
    showDialog(
      context: context,
      builder: (BuildContext c) {
        return AlertDialog(
          title: const Text('Purchase Confirmation'),
          content: Text(
            'Are you sure you want to purchase $emoji ?',
            textScaleFactor: 1,
          ),
          actions: [
            TextButton(
              onPressed: () {
                String successText = 'Purchase successful!';
                var snackBar = SnackBar(
                  duration: const Duration(seconds: 3),
                  backgroundColor: Colors.green,
                  content: Text(
                    successText,
                    textAlign: TextAlign.center,
                    ),
                );
                try {
                  buyEmoji(50, emoji);
                  setState(() {
                    unlockedAssets.add(emoji);
                  });
                  debugPrint(successText);
                } catch (e) {
                  successText = 'Purchase unsuccessful';
                  debugPrint('$successText: $e');
                }
                Navigator.of(context).pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              child: const Text('Yes')),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No')
            )
          ]
        );
      }
    );
  }

  void deleteAccountConfirmation() {
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
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
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
              child: const Text('No')
            )
          ]
        );
      }
    );
  }


  Widget emojiOption(String emoji) {
    return Container(
      child: unlockedAssets.contains(emoji)
      ? TextButton(
          onPressed: () {
            updateMyEmoji(emoji);
          },
          child: SizedBox(
            height: 50,
            width: 50,
            child: Text(
            emoji,
            textScaleFactor: 2.5,
            ),
          ),
        )
      : TextButton(
          onPressed: () async {
            if (points < 50) {
              var snackBar = const SnackBar(
                duration: Duration(seconds: 3),
                backgroundColor: Colors.red,
                content: Text(
                  'Not enough points',
                  textAlign: TextAlign.center,
                  ),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            } else {
              confirmationAndPurchase(emoji);
            }
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Text(
                  emoji,
                  textScaleFactor: 2.5,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.2)
                  ),
                ),
              const Positioned(
                bottom: 22,
                right: 25,
                child: Icon(
                  Icons.lock,
                  color: Color.fromARGB(255, 114, 114, 114),
                ),
              ),
              Positioned(
                top: 22,
                left: 25,
                child: Text(
                  '50P',
                  style: TextStyle(
                    color: MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? Colors.white
                      : Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          )
        )
      );
  }

  @override
  Widget build(BuildContext context) {
    return PollsTheme( 
      builder:(context, theme) => Scaffold (
        body: Container(
          color: theme.scaffoldBackgroundColor,
          alignment: Alignment.center,
          child: Flex(
            direction: Axis.vertical,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 25),
                    child: Column(
                      children: [
                        //Title
                        Text(
                          'My Profile',
                          textScaleFactor: 2,
                          style: TextStyle(
                            color: theme.indicatorColor,
                            fontWeight: FontWeight.bold,
                          )
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 40, horizontal: 50
                          ),
                          child: Column(
                            children: [
                              // emoji pfp & dropdown
                              TextButton(
                                style: ButtonStyle(
                                  shape: const MaterialStatePropertyAll(StadiumBorder()),
                                  padding: const MaterialStatePropertyAll(EdgeInsets.all(5)),
                                  overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                      return Colors.black.withOpacity(0);
                                  }),
                                  shadowColor: const MaterialStatePropertyAll(Colors.black12),
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    SizedBox(
                                      height: 100,
                                      child: Text(
                                        userEmoji,
                                        textScaleFactor: 6,
                                      ),
                                    ),
                                    Positioned(
                                      top: 70,
                                      left: 80,
                                      child: Container(
                                        height: 30,
                                        width: 41,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.circular(100),
                                          color: Colors.white,
                                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 0)],
                                        ),
                                        child: Stack(
                                          children: [
                                            const Positioned(
                                              top: 3,
                                              left: 5,
                                                child: Icon(
                                                Icons.create_outlined,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Positioned(
                                               top: 8,
                                               left: 22,
                                              child: 
                                              Text(
                                                dropdownState,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (emojiBoxHeight! > 0) {
                                      emojiBoxHeight = 0;
                                      dropdownState = "▲";
                                    } else {
                                      emojiBoxHeight = 140;
                                      dropdownState = "▼";
                                    }
                                  });
                                },
                              ),

                              const SizedBox(height: 5),

                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                height: emojiBoxHeight,
                                color: Colors.black.withOpacity(0.1),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Wrap(
                                    direction: Axis.horizontal,
                                    alignment: WrapAlignment.center,
                                    clipBehavior: Clip.hardEdge,
                                    children: [
                                      emojiOption(defaultEmoji),
                                      emojiOption('😂'),
                                      emojiOption('😍'),
                                      emojiOption('😄'),
                                      emojiOption('🙄'),
                                      emojiOption('😘'),
                                      emojiOption('🥺'),
                                      emojiOption('😎'),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 5),

                              Column(
                                children: [
                                  Text(
                                    '${PollarAuth.getEmail()}',
                                    style: TextStyle(
                                      color: theme.indicatorColor,
                                      fontSize: 20,
                                      //fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Points: ${setStateFromAnotherPagePoints()}',
                                    style: TextStyle(
                                      color: theme.indicatorColor,
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 25),


                              // Change emoji functionality
                              // TextButton(
                              //   child: Text(
                              //       dropdownState,
                              //       style: const TextStyle(
                              //         color: Colors.white,
                              //         fontSize: 16,
                              //       )),
                              //   onPressed: () {
                              //     setState(() {
                              //       if (emojiBoxHeight! > 0) {
                              //         emojiBoxHeight = 0;
                              //         dropdownState = "Change Profile Emoji  ▲";
                              //       } else {
                              //         emojiBoxHeight = 140;
                              //         dropdownState = "Change Profile Emoji  ▼";
                              //       }
                              //     });
                              //   },
                              // ),

                              // testing use only
                              // TextButton(
                              //   onPressed: () {
                              //     addPoints(10);
                              //     updatePoints(10);
                              //   }, 
                              //   child: const Text(
                              //     'FREE 10 POINTS'
                              //   ),
                              // ),

                              // change email
                              // TextButton(
                              //   style: ButtonStyle(
                              //     backgroundColor: MaterialStatePropertyAll(
                              //         Colors.black.withOpacity(0.2)),
                              //   ),
                              //   child: const Text(
                              //     "Change Email",
                              //     style: TextStyle(
                              //       color: Colors.white,
                              //       fontSize: 17,
                              //     ),
                              //   ),
                              //   onPressed: () {
                              //     // prompt for password
                              //     // send emai
                              //   },
                              // ),

                              // const SizedBox(height: 20),

                              //change password button
                              // ISSUE: 1st pass reset email gets sent to spam, need to connect email to custom domain
                              TextButton(
                                child: Text(
                                  "Reset Password",
                                  style: TextStyle(
                                    color: theme.indicatorColor,
                                    fontSize: 17,
                                  ),
                                ),
                                onPressed: () async{
                                  PollarAuth.resetPassword();
                                  var passResetSnackBar = const SnackBar(
                                    duration: Duration(seconds: 3),
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      'Password reset link sent to email',
                                      textAlign: TextAlign.center,
                                      ),
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(passResetSnackBar);
                                  }
                                },
                              ),
                              const SizedBox(height: 15),

                              // sign out button
                              TextButton(
                                child: Text("Sign out",
                                    style: TextStyle(
                                      color: theme.indicatorColor,
                                      fontSize: 17,
                                    )),
                                onPressed: () async {
                                  PollarAuth.signOut();
                                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
                                  
                                },
                              ),

                              // For testing purposes
                              const SizedBox(height: 50),
                              TextButton(
                                child: const Text("Delete Account",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 17,
                                    )),
                                onPressed: () async {
                                  deleteAccountConfirmation();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}