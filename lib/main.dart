import 'package:flutter/material.dart';
import 'package:pollar/services/shared_preferences_service.dart';
import 'package:pollar/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';

void main() async {
  //DO NOT EDIT
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  ///

  //Initilize shared_preferences Singleton Class
  SharedPreferencesService.getInstance().then((service) {
    var preferences = service!.preferences;
  // Use preferences to read/write values from anywhere in app
  });
  
  
  runApp(const PollsApp());
}

class PollsApp extends StatelessWidget {
  const PollsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pollar',
      home: Wrapper(),
    );
  }
}