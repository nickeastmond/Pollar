

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pollar/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

 Future<bool> checkPermission() async {
  final status = await Permission.locationWhenInUse.status;
  if (status.isGranted) {
    // Permission is already granted
    return true;
  } else {
    // Permission is not granted, request it
    bool granted = await requestPermission();
    if (granted) {
      return true;
    }
    else {
      return false;
    }
  }
}

Future<bool> requestPermission() async {
  final status = await Permission.locationWhenInUse.request();
  print("Location status is: ${status}");
  if (status.isGranted) {
    // Permission granted
    return true;
  } else {
    // Permission not granted
    return false;
  }
}



void main() async {
  //DO NOT EDIT
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.remove('Radius');
  preferences.remove('virtualLocation');
  preferences.remove('physicalLocation');
  bool locationGranted =  await checkPermission();
  
  if (!locationGranted) {
    SystemNavigator.pop();
  }
  
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