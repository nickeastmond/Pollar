import 'package:flutter/material.dart';
import 'package:pollar/services/auth.dart';
import 'package:pollar/model/user/pollar_user_model.dart';
import 'package:pollar/login/login_page.dart';
import '../polls_theme.dart';

String? setPollarUserEmoji(String emoji) {
  PollarAuth.setDisplayName(emoji);
  return emoji;
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  double? emojiBoxHeight = 0;
  String? profEmoji = PollarAuth.getDisplayName();

  @override
  initState() {
    super.initState();
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
      builder:(context, theme) => Scaffold (
        body: Container(
          color: theme.primaryColor,
          alignment: Alignment.center,
          child: Flex(
            direction: Axis.vertical,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 50, horizontal: 40),
                    child: Column(
                      children: [
                        // emoji pfp
                        SizedBox(
                          height: 100,
                          child: 
                          //if no saved emoji:
                          Text(
                            profEmoji!,
                            textScaleFactor: 6,
                          ),
                        ),
                        const SizedBox(height: 25),
                        // Change emoji functionality

                        TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Colors.black.withOpacity(0.2))),
                          child: const Text("Change Profile Emoji",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                              )),
                          onPressed: () {
                            setState(() {
                              (emojiBoxHeight! > 0) ? emojiBoxHeight = 0 : emojiBoxHeight = 100;
                              });
                          },
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: emojiBoxHeight,
                          color: Colors.black.withOpacity(0.2),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 25),
                          child: Flex(
                            direction: Axis.horizontal,
                            mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                            children: [
                              emojiOption(defaultEmoji),
                              emojiOption('😂'),
                              emojiOption('😍'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),
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
                              const SizedBox(height: 25),
                              // change email
                              TextButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                      Colors.black.withOpacity(0.2)),
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
                              const SizedBox(height: 25),
                              //change password button
                              TextButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                      Colors.black.withOpacity(0.2)),
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
                        const SizedBox(height: 25),

                        // sign out button
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                                Colors.black.withOpacity(0.2)),
                          ),
                          child: const Text("Sign out",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                              )),
                          onPressed: () async {
                            PollarAuth.signOut().then((_) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const LoginPage()),
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
      ),
    );
  }
}