import 'package:flutter/material.dart';
import 'package:pollar/services/auth.dart';
import 'package:pollar/model/user/database/get_user_db.dart';
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
  //String userEmoji = getEmoji();
  String changeEmojiText = 'Change Profile Emoji  ▲';
  double? emojiBoxHeight = 0;
  String  notVerifiedText = '⚠ Unverified email. Press for verification link.';
  bool unverifiedTextVisibility = true;
  bool resetPassSent = false;
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
        //setEmoji(emoji);
        print('hi');
        setState(() {
          emojiBoxHeight = 0;
          
        });
      },
      child: Text(
        emoji,
        textScaleFactor: 2.5,
      ),
    );
  }

  void changePassword() {
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
                            defaultEmoji,
                            textScaleFactor: 6,
                          ),
                        ),
                        const SizedBox(height: 13),
                        // Change emoji functionality

                        TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Colors.black.withOpacity(0.2))),
                          child: Text(
                              changeEmojiText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              )),
                          onPressed: () {
                            setState(() {
                              if (emojiBoxHeight! > 0) {
                                emojiBoxHeight = 0;
                                changeEmojiText = "Change Profile Emoji  ▲";
                               } else {
                                emojiBoxHeight = 100;
                                changeEmojiText = "Change Profile Emoji  ▼";
                               }
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

                        Column(
                          children: [
                            Text(
                              '${PollarAuth.getEmail()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),

                            // ignore for now, button does nothing
                            // Visibility(
                            //   visible: PollarAuth.isVerified()! ? false : true,
                            //   child: TextButton(
                            //     child: const Text(
                            //         '⚠ Unverified email. Press for verification link.',
                            //         style: TextStyle(
                            //           color: Colors.red,
                            //           fontSize: 14,
                            //       ),
                            //     ),
                            //     onPressed: () {
                            //       //PollarAuth.verifyEmail();
                            //       var verifyEmailSnackBar = const (
                            //         duration: Duration(seconds: 3),
                            //         backgroundColor: Colors.red,
                            //         content: Text(
                            //           'Verification link has been sent to email',
                            //           textAlign: TextAlign.center,
                            //           ),
                            //       );
                            //       if (context.mounted) {
                            //         ScaffoldMessenger.of(context).showSnackBar(verifyEmailSnackBar);
                            //       }
                            //     },
                            //   ),
                            // ),

                          ],
                        ),
                        const SizedBox(height: 20),
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
                            // prompt for password
                            // send emai
                          },
                        ),
                        const SizedBox(height: 25),
                        //change password button
                        // ISSUE: 1st pass reset email gets sent to spam, need to connect email to custom domain
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                                Colors.black.withOpacity(0.2)),
                          ),
                          child: const Text(
                            "Reset Password",
                            style: TextStyle(
                              color: Colors.white,
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