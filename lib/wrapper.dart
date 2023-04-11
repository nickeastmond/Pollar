import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pollar/services/auth.dart';
import 'login/login_page.dart';
import 'navigation/navigation_page.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});


  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print("Is user signed in?: ${PollarAuth.isUserSignedIn()}");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (PollarAuth.isUserSignedIn() ) {
          return const NavigationPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
