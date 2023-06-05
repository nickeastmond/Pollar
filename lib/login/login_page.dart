//  Created by Nicholas Eastmond on 10/5/22.

import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pollar/login/firebase_user_login.dart';
import 'package:pollar/login/signup_page.dart';
import 'package:pollar/model/user/pollar_user_model.dart';
import 'package:pollar/navigation/navigation_page.dart';
import 'package:pollar/polls/bar_graph.dart';
import 'package:pollar/services/auth.dart';

import '../polls_theme.dart';
import 'custom_page_route.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  int tabSelected = 0; // initially tab selected is poll feed
  int sinVal = 0;
  late AnimationController _controller;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  @override
  void initState() {
    super.initState();

    if (mounted)
    {
      updateSinValue();
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
    
  }

  void updateSinValue() {
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      sinVal = (sin(DateTime.now().millisecondsSinceEpoch / 500) * 100) ~/ 15;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return PollsTheme(builder: (context, theme) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            AnimatedBuilder(
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
                    ),
                    child: Center(
                      child: SizedBox(
                        height: 550,
                        child: AutofillGroup(
                          child: Column(
                            children: [
                              const Center(
                                child: Icon(
                                  Icons.bar_chart,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              const Center(
                                child: Text(
                                  "Pollar",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              Container(
                                height: 55,
                                width: 400,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                decoration: BoxDecoration(
                                    color: Colors.white,
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
                                    borderRadius: BorderRadius.circular(0)),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: TextField(
                                      textInputAction: TextInputAction.next,
                                      keyboardType: TextInputType.emailAddress,
                                      autofillHints: const [
                                        AutofillHints.email
                                      ],
                                      cursorColor: Colors.black,
                                      minLines: 1,
                                      autocorrect: false,
                                      controller: emailController,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        enabled: true,
                                        contentPadding: const EdgeInsets.only(
                                          left: 12.0,
                                          right: 12.0,
                                          top: 8.0,
                                          bottom: 8.0,
                                        ),
                                        filled: false,
                                        fillColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        labelText: "Email",
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                height: 55,
                                width: 400,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                decoration: BoxDecoration(
                                    color: Colors.white,
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
                                    borderRadius: BorderRadius.circular(0)),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: TextField(
                                      onEditingComplete: () =>
                                          TextInput.finishAutofillContext(),
                                      textInputAction: TextInputAction.next,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      autofillHints: const [
                                        AutofillHints.password
                                      ],
                                      cursorColor: Colors.black,
                                      minLines: 1,
                                      autocorrect: false,
                                      controller: passwordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        enabled: true,
                                        contentPadding: const EdgeInsets.only(
                                          left: 12.0,
                                          right: 12.0,
                                          top: 8.0,
                                          bottom: 8.0,
                                        ),
                                        filled: false,
                                        fillColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        labelText: "Password",
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              Container(
                                height: 55,
                                width: 600,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          color:
                                              const Color.fromARGB(20, 0, 0, 0),
                                          blurRadius: 4,
                                          spreadRadius: 4,
                                          blurStyle: BlurStyle.normal,
                                          offset:
                                              Offset.fromDirection(pi / 2, 4))
                                    ],
                                    color: theme.secondaryHeaderColor,
                                    borderRadius: BorderRadius.circular(0)),
                                child: TextButton(
                                    child: const Text(
                                      "Sign In",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    onPressed: () async {
                                      String error =
                                          await FirebaseLogin.firebaseUserLogin(
                                              emailController.text,
                                              passwordController.text);
                                      debugPrint(error);

                                      if (error.isEmpty) {
                                        if (PollarAuth.isVerified() == null) {
                                          error = 'Internal error';
                                          debugPrint(
                                              'verification status is null');
                                          PollarAuth.signOut();
                                        } else if (!PollarAuth.isVerified()!) {
                                          error =
                                              'Email is not verified. We have sent you another link for you to verify your email to log in.';
                                          PollarAuth.sendVerification();
                                          PollarAuth.signOut();
                                        } else {
                                          await fetchUserInfoFromFirebaseToSharedPrefs();
                                        }
                                      }

                                      var snackBar = SnackBar(
                                        duration: const Duration(seconds: 3),
                                        backgroundColor:
                                            theme.secondaryHeaderColor,
                                        content: Text(
                                          error,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      );

                                      if (context.mounted && error.isNotEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                      } else if (context.mounted) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const NavigationPage()));
                                      }
                                    }),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            Positioned(
                bottom: 0,
                left: 10,
                child: BarGraph(
                  height: 275,
                  width: MediaQuery.of(context).size.width / 2,
                  counters: [
                    10 + sinVal.abs(),
                    20 - 2 * sinVal.abs(),
                    13 + sinVal.abs(),
                    25 - 3 * sinVal.abs(),
                    35 - (4 * sinVal.abs()),
                  ],
                  numBars: 5,
                  spacing: 20,
                  circleBorder: 0,
                )),
            Positioned(
                bottom: 0,
                right: 10,
                child: BarGraph(
                  height: 225,
                  width: MediaQuery.of(context).size.width / 2,
                  counters: [
                    35 - 5 * sinVal.abs(),
                    23 - 2 * sinVal.abs(),
                    13 + sinVal.abs(),
                    20 + 3 * sinVal.abs(),
                    10 + 4 * sinVal.abs(),
                  ],
                  numBars: 5,
                  spacing: 20,
                  circleBorder: 0,
                )),
            Positioned(
              bottom: 20,
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: <Widget>[
                  const Spacer(),
                  const Text(
                    "Forgot password?",
                    style: TextStyle(
                      color: Colors.white,
                      shadows: [
                        // Shadow(
                        //   blurRadius: 10,
                        //   color: Color.fromARGB(150, 0, 0, 0),
                        // ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await FirebaseAuth.instance
                          .sendPasswordResetEmail(email: emailController.text);
                      var passResetSnackBar = SnackBar(
                        duration: const Duration(seconds: 3),
                        backgroundColor: theme.secondaryHeaderColor,
                        content: const Text(
                          'Password reset link sent to email',
                          textAlign: TextAlign.center,
                        ),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(passResetSnackBar);
                      }
                    },
                    child: Text(
                      "Reset Password",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade200,
                        shadows: const [
                          Shadow(
                            blurRadius: 10,
                            color: Color.fromARGB(150, 0, 0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Positioned(
              bottom: 45,
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: <Widget>[
                  const Spacer(),
                  const Text(
                    "No account yet?",
                    style: TextStyle(
                      color: Colors.white,
                      // shadows: [
                      //   Shadow(
                      //     blurRadius: 10,
                      //     color: Color.fromARGB(150, 0, 0, 0),
                      //   ),
                      // ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(CustomPageRoute(const SignUpPage()));
                    },
                    child: Text(
                      "Sign Up!",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade200,
                        shadows: const [
                          Shadow(
                            blurRadius: 10,
                            color: Color.fromARGB(150, 0, 0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
