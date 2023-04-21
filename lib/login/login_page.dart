//  Created by Nicholas Eastmond on 10/5/22.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pollar/login/firebase_user_login.dart';
import 'package:pollar/login/signup_page.dart';
import 'package:pollar/model/user/pollar_user_model.dart';
import 'package:pollar/navigation/navigation_page.dart';

import '../polls_theme.dart';
import 'custom_page_route.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  int tabSelected = 0; // initially tab selected is poll feed

  @override
  Widget build(BuildContext context) {
    return PollsTheme(builder: (context, theme) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Container(
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
                          margin: const EdgeInsets.symmetric(horizontal: 30),
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
                              borderRadius: BorderRadius.circular(0)),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: TextField(
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
                          margin: const EdgeInsets.symmetric(horizontal: 30),
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
                              borderRadius: BorderRadius.circular(0)),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: TextField(
                                onEditingComplete: () =>
                                    TextInput.finishAutofillContext(),
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.visiblePassword,
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
                          margin: const EdgeInsets.symmetric(horizontal: 30),
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

                                var snackBar = SnackBar(
                                  duration: const Duration(seconds: 3),
                                  backgroundColor: Colors.red,
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
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const NavigationPage()));
                                }
                              }),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: <Widget>[
                  const Spacer(),
                  const Text(
                    "No account yet?",
                    style: TextStyle(color: Colors.white),
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
