import 'package:flutter/material.dart';
import 'login/login_page.dart';
import 'navigation/navigation_page.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: null,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return const NavigationPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
