import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pollar/model/user/database/get_user_db.dart';
import 'package:pollar/model/user/pollar_user_model.dart';
import 'login/login_page.dart';
import 'package:rxdart/rxdart.dart';

import 'navigation/navigation_page.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool allowEntry = false;

  @override
  void initState() 
  {
    super.initState();
    try
    {
      getUserById(FirebaseAuth.instance.currentUser!.uid).then((PollarUser? user)
    {
      print("User is: ${user}");
      if (user != null)
      {

        if (mounted)
        {
          setState(() {
            allowEntry = true;
          });
        }
      }
      else 
      {
         if (mounted)
        {
          setState(() {
            allowEntry = false;
          });
        }
      }
    });
    }
    catch(e)
    {
      allowEntry = false;
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges().startWith(FirebaseAuth.instance.currentUser),
      builder: (context, snapshot) {
        debugPrint("Is user signed in?: ${snapshot.hasData}");
        if (snapshot.connectionState == ConnectionState.waiting) {
          debugPrint("we are waiting");
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && allowEntry == true) {
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