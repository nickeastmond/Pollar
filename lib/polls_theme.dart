//  Created by Nicholas Eastmond on 9/26/22.

import 'package:flutter/material.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

typedef PollsThemeBuilder = Widget Function(
    BuildContext context, ThemeData theme);

class PollsTheme extends StatefulWidget {
  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.teal,
    secondaryHeaderColor: const Color.fromARGB(255, 248, 182, 82),
    unselectedWidgetColor: Colors.white,
    cardColor: Colors.white,
    indicatorColor: Colors.grey.shade800,
  );

  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: const Color.fromARGB(255, 25, 25, 25),
    primaryColor: Colors.grey.shade900,
    secondaryHeaderColor: Colors.grey.shade800,
    indicatorColor: Colors.white,
    unselectedWidgetColor: Colors.white,
    cardColor: Colors.grey.shade900,
  );

  static ThemeData automaticTheme(BuildContext context) =>
      MediaQuery.of(context).platformBrightness == Brightness.light
          ? PollsTheme.lightTheme
          : PollsTheme.darkTheme;

  static const _themeKey = "theme";
  const PollsTheme({super.key, required this.builder});
  final PollsThemeBuilder builder;

  @override
  State<PollsTheme> createState() => _PollsThemeState();

  static Future<void> _setTheme(String theme) async =>
      (await StreamingSharedPreferences.instance).setString(_themeKey, theme);

  static void setLight() => _setTheme("light");
  static void setDark() => _setTheme("dark");
  static void setAuto() => _setTheme("automatic");
}

class _PollsThemeState extends State<PollsTheme> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: StreamingSharedPreferences.instance,
      builder: (context, prefs) => StreamBuilder<ThemeData>(
        stream: prefs.data
            ?.getString("theme", defaultValue: "automatic")
            .asyncMap((themeName) => _theme(themeName, context)),
        builder: (context, snapshot) => widget.builder(
            context, snapshot.data ?? PollsTheme.automaticTheme(context)),
      ),
    );
  }

  ThemeData _theme(String themeName, BuildContext context) =>
      themeName == "light"
          ? PollsTheme.lightTheme
          : themeName == "dark"
              ? PollsTheme.darkTheme
              : PollsTheme.automaticTheme(context);
}
