import 'package:flutter/material.dart';
import 'package:pollar/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  //DO NOT EDIT
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
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