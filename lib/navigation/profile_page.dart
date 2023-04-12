import 'package:flutter/material.dart';
import 'package:pollar/services/auth.dart';

String? setPollarUserEmoji(String emoji) {
  PollarAuth.setDisplayName(emoji);
  return emoji;
}

String futureToString(Future<String> fs) {
  String str = 'Unable to convert Future<String> to String';
  FutureBuilder<String>(
    future: fs,
    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
      if (snapshot.hasData) {
        str = '${snapshot.data}';
      }
      return Text(str);
    },
  );
  print("fts: ${str}");
  return str;
}