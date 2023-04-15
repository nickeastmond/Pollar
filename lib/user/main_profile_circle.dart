import 'package:flutter/material.dart';

class MainProfileCircleWidget extends StatelessWidget {
  const MainProfileCircleWidget(
      {Key? key,
      required this.fillColor,
      required this.borderColor,
      required this.size,
      required this.width,
      required this.emojiSize,
      this.emojiListUnlocked = const [],
      this.colorListUnlocked = const [],
      required this.emoji})
      : super(key: key);
  final Color fillColor;
  final Color borderColor;
  final double size;
  final String emoji;
  final double width;
  final double emojiSize;
  final List<String> emojiListUnlocked;
  final List<Color> colorListUnlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: fillColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.4),
              spreadRadius: 0,
              blurRadius: 0,
            ),
          ],
          border: Border.all(color: borderColor, width: width)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 3,
          ),
          child: Text(
            emoji,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: emojiSize,
            ),
          ),
        ),
      ),
    );
  }
}
