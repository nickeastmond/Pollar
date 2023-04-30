import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login/login_page.dart';
import 'package:rxdart/rxdart.dart';

import 'navigation/navigation_page.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key});
  

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges().startWith(FirebaseAuth.instance.currentUser),
      builder: (context, snapshot) {
        debugPrint("Is user signed in?: ${snapshot.hasData}");
        if (snapshot.connectionState == ConnectionState.waiting) {
          debugPrint("we are waiting");
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          debugPrint("SHOW NAV PAGE!");
          return const NavigationPage();
        } else {
          debugPrint("user not signed in: ${snapshot.hasData}");
          return const LoginPage();
        }
      },
    );
  }
}