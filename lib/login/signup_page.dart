//  Created by Nicholas Eastmond on 10/5/22.

import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../services/auth.dart';
import 'firebase_user_signup.dart';
import '../polls_theme.dart';

import 'package:email_validator/email_validator.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({
    super.key,
  });

  @override
  State<SignUpPage> createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController confirmEmailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  int tabSelected = 0; // initially tab selected is poll feed
  bool signUpCriteriaMet = true;

  @override
  Widget build(BuildContext context) {
    return PollsTheme(
      builder: (context, theme) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const Alignment(0, -0.25),
                end: Alignment.bottomCenter,
                colors: <Color>[
                  theme.primaryColor,
                  theme.secondaryHeaderColor,
                ],
              ),
            ),
            child: Stack(
              children: [
                const Positioned(
                  top: 50,
                  left: 20,
                  child: BackButton(
                    color: Colors.white,
                  ),
                ),
                Center(
                  child: SizedBox(
                    height: 550,
                    child: AutofillGroup(
                      child: Column(
                        children: [
                          const Center(
                            child: Icon(
                              Icons.bar_chart_rounded,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                          const Center(
                            child: Text(
                              "Sign Up",
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          Container(
                            height: 55,
                            width: 400,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: const Color.fromARGB(15, 0, 0, 0),
                                      blurRadius: 4,
                                      spreadRadius: 4,
                                      blurStyle: BlurStyle.normal,
                                      offset: Offset.fromDirection(pi / 2, 4))
                                ],
                                borderRadius: BorderRadius.circular(30)),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.email],
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
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    labelText: "Email",
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.never,
                                  ),
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  // still need to check if email is legit/exists
                                  validator: (email) {
                                    if (email == null || !EmailValidator.validate(email)) {
                                      signUpCriteriaMet = false;
                                      return 'Please enter a valid email';
                                    }
                                      signUpCriteriaMet = true;
                                      return null;
                                  },
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
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: const Color.fromARGB(15, 0, 0, 0),
                                      blurRadius: 4,
                                      spreadRadius: 4,
                                      blurStyle: BlurStyle.normal,
                                      offset: Offset.fromDirection(pi / 2, 4))
                                ],
                                borderRadius: BorderRadius.circular(30)),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.password],
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
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    labelText: "Password",
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.never,
                                  ),
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  // For now, pass requirement is need to contain at least 6 chars
                                  validator: (password) {
                                    if (password != null && password.length < 6) {
                                      signUpCriteriaMet = false;
                                      return 'Password must be at least 6 characters long';
                                    }
                                    signUpCriteriaMet = true;
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 55,
                            width: 400,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: const Color.fromARGB(15, 0, 0, 0),
                                      blurRadius: 4,
                                      spreadRadius: 4,
                                      blurStyle: BlurStyle.normal,
                                      offset: Offset.fromDirection(pi / 2, 4))
                                ],
                                borderRadius: BorderRadius.circular(30)),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.password],
                                  cursorColor: Colors.black,
                                  minLines: 1,
                                  autocorrect: false,
                                  controller: confirmPasswordController,
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
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    labelText: "Confirm Password",
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.never,
                                  ),
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: (confirmPassword) {
                                    if (confirmPassword != passwordController.text) {
                                      signUpCriteriaMet = false;
                                      return 'Passwords do not match';
                                    }
                                      signUpCriteriaMet = true;
                                      return null;
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          Container(
                            height: 55,
                            width: 450,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: const Color.fromARGB(20, 0, 0, 0),
                                      blurRadius: 4,
                                      spreadRadius: 4,
                                      blurStyle: BlurStyle.normal,
                                      offset: Offset.fromDirection(pi / 2, 4))
                                ],
                                color: theme.secondaryHeaderColor,
                                borderRadius: BorderRadius.circular(30)),
                            child: TextButton(
                                child: const Text(
                                  "Sign Up",
                                ),
                                onPressed: () async {
                                  if (passwordController.text == confirmPasswordController.text){
                                  FirebaseSignup.firebaseUserSignup(
                                              emailController.text,
                                              passwordController.text,
                                            ).then((_) {
                                              if (PollarAuth.isUserSignedIn()) {
                                                Navigator.pop(context);
                                              }
                                            }); // pop the current route off the stack);
                                  }
                                }),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 35,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(height: 1.5, shadows: []),
                        children: <TextSpan>[
                          const TextSpan(
                            text: "By signing up, you agree to our  ",
                          ),
                          TextSpan(
                            text: "Terms",
                            recognizer: TapGestureRecognizer()..onTap = (() {}),
                          ),
                          const TextSpan(
                            text: ", ",
                          ),
                          TextSpan(
                            text: "Privacy Policy",
                            recognizer: TapGestureRecognizer()..onTap = (() {}),
                          ),
                          const TextSpan(
                            text: ", and ",
                          ),
                          TextSpan(
                            text: "Community Guidelines",
                            recognizer: TapGestureRecognizer()..onTap = (() {}),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
