import 'package:flutter/material.dart';
import 'package:pollar/wrapper.dart';

void main() async {
  runApp(const PollsApp());
}

class PollsApp extends StatelessWidget {
  const PollsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rolli Polli',
      home: Wrapper(),
    );
  }
}