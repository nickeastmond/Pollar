import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pollar/navigation/profilePages/participation_history_page.dart';
import 'package:pollar/navigation/profilePages/polls_created_page.dart';
import 'package:pollar/services/auth.dart';
import 'package:pollar/services/feeds/polls_created_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pollar/model/user/pollar_user_model.dart';
import 'package:pollar/login/login_page.dart';
import '../polls_theme.dart';
import '../services/feeds/participation_history_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  String? userEmoji = defaultEmoji;
  String? sprefEmoji = 'null';
  int userEmojiBgColorVal = defaultEmojiBgColor.value;
  int sprefEmojiBgColorVal = -1;
  List<dynamic> unlockedAssets = [];
  String dropdownState = '▲';
  double? emojiBoxHeight = 0;
  bool unverifiedTextVisibility = true;
  bool resetPassSent = false;

  late AnimationController _controller;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;
  late List<Color> colors = generateAllColorsHSL();
  List<Color> generateAllColorsHSL() {
    List<Color> allColorsHSL = [];
    Set<Color> uniqueColors = {};
    allColorsHSL.add(Colors.white);
    allColorsHSL.add(Colors.grey[400]!);
    allColorsHSL.add(Colors.grey[700]!);
    allColorsHSL.add(Colors.black);

    for (int hue = 0; hue <= 360; hue += 9) {
      for (int saturation = 20; saturation <= 80; saturation += 20) {
        for (int lightness = 20; lightness <= 80; lightness += 20) {
          Color color = HSLColor.fromAHSL(
            1.0,
            hue.toDouble(),
            saturation.toDouble() / 100,
            lightness.toDouble() / 100,
          ).toColor();

          if (!uniqueColors.contains(color)) {
            uniqueColors.add(color);
            allColorsHSL.add(color);
          }
        }
      }
    }

    return allColorsHSL;
  }

  @override
  initState() {
    updateMyEmoji('');
    updateMyEmojiBgColor(-2);
    updatePoints(0);
    fetchAssets();
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 8));
    _topAlignmentAnimation = TweenSequence<Alignment>(
      [
        TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.topLeft, end: Alignment.topRight),
          weight: 0.25,
        ),
        TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.topRight, end: Alignment.bottomRight),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.bottomRight, end: Alignment.bottomLeft),
          weight: 0.25,
        ),
        TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.bottomLeft, end: Alignment.topLeft),
          weight: 1,
        ),
      ],
    ).animate(_controller);

    _bottomAlignmentAnimation = TweenSequence<Alignment>(
      [
        TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.bottomRight, end: Alignment.bottomLeft),
          weight: 0.25,
        ),
        TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.bottomLeft, end: Alignment.topLeft),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.topLeft, end: Alignment.topRight),
          weight: 0.25,
        ),
        TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.topRight, end: Alignment.bottomRight),
          weight: 1,
        ),
      ],
    ).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Fetches list of unlocked profile customization assets from Firebase
  // into unlockedAssets
  void fetchAssets() async {
    if (mounted) {
      List<dynamic> temp = await getUnlockedAssets();

      setState(() {
        unlockedAssets = temp;
      });
    }
  }

  // Fetches user's display emoji from shared preferences into userEmoji
  void updateMyEmoji(String emoji) async {
    final prefs = await SharedPreferences.getInstance();
    sprefEmoji = prefs.getString('emoji') ?? "null";
    debugPrint('spref emoji: $sprefEmoji');
    // new user
    if (sprefEmoji == 'null') {
      prefs.setString('emoji', defaultEmoji);

      // existing user
    } else if (emoji != '') {
      setEmoji(emoji);
      prefs.setString('emoji', emoji);
    }
    setState(() {
      sprefEmoji = prefs.getString('emoji')!;
      userEmoji = sprefEmoji;
    });
  }

  // Fetches user's background profile color from shared
  // preferences into userEmojiBgColorVal
  // --- Notes ---
  // -1 wil be used to represent a new user
  // -2 will be used to update the color and nothing else
  void updateMyEmojiBgColor(int colorVal) async {
    final prefs = await SharedPreferences.getInstance();
    sprefEmojiBgColorVal = prefs.getInt('emojiBgColorVal') ?? -1;
    // new user
    if (sprefEmojiBgColorVal == -1) {
      prefs.setInt('emojiBgColorVal', defaultEmojiBgColor.value);

      // existing user
    } else if (colorVal > -1) {
      setEmojiBgColor(colorVal);
      prefs.setInt('emojiBgColorVal', colorVal);
    }
    setState(() {
      sprefEmojiBgColorVal = prefs.getInt('emojiBgColorVal')!;
      userEmojiBgColorVal = sprefEmojiBgColorVal;
    });
  }

  // Fetches current amount of user's points from shared
  // preferences into points
  void updatePoints(int num) async {
    final prefs = await SharedPreferences.getInstance();
    sprefPoints = prefs.getInt('points') ?? -1;
    // new user
    if (sprefPoints == -1) {
      prefs.setInt('points', 0);

      // existing user
    } else if (num > 0) {
      addPoints(num);
      prefs.setInt('points', sprefPoints! + num);
    }
    setState(() {
      sprefPoints = prefs.getInt('points')!;
      points = sprefPoints;
    });
  }

  // Use this to immediately reflect real-time changes
  // to user's points (especially if changes were
  // made by another page)
  int setStateFromAnotherPagePoints() {
    updatePoints(0);
    return points!;
  }

  // Use this to immediately reflect real-time changes
  // to user's display emoji
  String setStateFromThisPageEmoji() {
    updateMyEmoji('');
    return userEmoji!;
  }

  // Prompts user for confirmation before proceeding with
  // emoji-customiztion purchase transaction
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
                    child: const Text('No'))
              ]);
        });
  }

  // A button that shows an emoji available to
  // use as user's display emoji. If it is not
  // in the user's list of unlockedAssets, it will
  // show the emoji with a "locked/disabled" visual,
  // otherwise it will show as a normal emoji
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
                if (points! < 50) {
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
                    style: TextStyle(color: Colors.black.withOpacity(0.2)),
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
                        color: MediaQuery.of(context).platformBrightness ==
                                Brightness.dark
                            ? Colors.white
                            : Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PollsTheme(
      builder: (context, theme) => Scaffold(
        body: Container(
          color: theme.scaffoldBackgroundColor,
          alignment: Alignment.center,
          child: Flex(
            direction: Axis.vertical,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 13, horizontal: 16),
                        child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, _) {
                              return Container(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: _topAlignmentAnimation.value,
                                      end: _bottomAlignmentAnimation.value,
                                      colors: <Color>[
                                        theme.primaryColor,
                                        theme.secondaryHeaderColor,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                          color:
                                              const Color.fromARGB(15, 0, 0, 0),
                                          blurRadius: 4,
                                          spreadRadius: 4,
                                          blurStyle: BlurStyle.normal,
                                          offset:
                                              Offset.fromDirection(pi / 2, 4))
                                    ],
                                    borderRadius: BorderRadius.circular(15)),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 30, horizontal: 30),
                                      child: Column(
                                        children: [
                                          // emoji pfp & dropdown
                                          Container(
                                            height: 150,
                                            width: 150,
                                            decoration: BoxDecoration(
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Color.fromARGB(
                                                      25, 0, 0, 0),
                                                  blurRadius: 4,
                                                  spreadRadius: 4,
                                                  blurStyle: BlurStyle.normal,
                                                )
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              color: Colors.white,
                                            ),
                                            child: Center(
                                              child: Container(
                                                height: 130,
                                                width: 130,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  color: Color(
                                                      userEmojiBgColorVal),
                                                ),
                                                child: Padding(
                                                  padding: Platform.isAndroid
                                                      ? const EdgeInsets.only(
                                                          bottom: 0)
                                                      : const EdgeInsets.only(
                                                          bottom: 8.0),
                                                  child: Center(
                                                    child: SizedBox(
                                                      height: 100,
                                                      child: Text(
                                                        userEmoji!,
                                                        textScaleFactor: 6,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          Column(
                                            children: [
                                              const SizedBox(height: 24),
                                              Text(
                                                'Points: ${setStateFromAnotherPagePoints()}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w400,
                                                  shadows: [
                                                    Shadow(
                                                      color: Color.fromARGB(
                                                          100, 0, 0, 0),
                                                      blurRadius: 5,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 24),
                                          Container(
                                            height: 30,
                                            width: 41,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              color: Colors.white,
                                              boxShadow: const [
                                                BoxShadow(
                                                    color: Colors.black12,
                                                    blurRadius: 10,
                                                    spreadRadius: 0)
                                              ],
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
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
                                              child: const Icon(
                                                Icons.create_outlined,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),

                                          // Change emoji functionality
                                          const SizedBox(height: 2.5),
                                          AnimatedContainer(
                                            height:
                                                dropdownState != "▲" ? 12 : 0,
                                            duration: const Duration(
                                                milliseconds: 400),
                                          ),
                                          AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 250),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                            ),
                                            height: emojiBoxHeight,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 10),
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
                                          AnimatedContainer(
                                            height:
                                                dropdownState != "▲" ? 12 : 0,
                                            duration: const Duration(
                                                milliseconds: 400),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                            ),
                                            height: emojiBoxHeight,
                                            child: GridView.builder(
                                              padding: const EdgeInsets.all(30),
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 5,
                                                mainAxisSpacing: 16,
                                                crossAxisSpacing: 16,
                                              ),
                                              itemCount: colors.length,
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    // Handle color selection here
                                                    Color selectedColor =
                                                        colors[index];
                                                    updateMyEmojiBgColor(
                                                        selectedColor.value);
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: colors[index],
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            // Handle button tap here
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ChangeNotifierProvider<
                                    ParticipationHistoryProvider>(
                                  create: (_) => ParticipationHistoryProvider()
                                    ..fetchInitial(100),
                                  child: const ParticipationHistoryPage(),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color:
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark
                                      ? theme.primaryColor
                                      : theme.cardColor,
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    spreadRadius: 0),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 24,
                                  color: MediaQuery.of(context)
                                              .platformBrightness ==
                                          Brightness.light
                                      ? Colors.grey.shade700
                                      : Colors.white,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    "Participation History",
                                    style: TextStyle(
                                      height: 1.5,
                                      color: theme.indicatorColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 35,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ChangeNotifierProvider<
                                    PollsCreatedProvider>(
                                  create: (_) =>
                                      PollsCreatedProvider()..fetchInitial(100),
                                  child: const PollsCreatedPage(),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color:
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark
                                      ? theme.primaryColor
                                      : theme.cardColor,
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    spreadRadius: 0),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.poll_outlined,
                                  size: 24,
                                  color: MediaQuery.of(context)
                                              .platformBrightness ==
                                          Brightness.light
                                      ? Colors.grey.shade700
                                      : Colors.white,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    "Polls Created",
                                    style: TextStyle(
                                      height: 1.5,
                                      color: theme.indicatorColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 95,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            PollarAuth.signOut();
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                                (route) => false);
                          },
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color:
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark
                                      ? theme.primaryColor
                                      : theme.cardColor,
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    spreadRadius: 0),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.logout,
                                  size: 24,
                                  color: MediaQuery.of(context)
                                              .platformBrightness ==
                                          Brightness.light
                                      ? Colors.grey.shade700
                                      : Colors.white,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    "Sign Out",
                                    style: TextStyle(
                                      height: 1.5,
                                      color: theme.indicatorColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 125,
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
            ],
          ),
        ),
      ),
    );
  }
}
