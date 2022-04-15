import 'package:aqromis_application/constants.dart';
import 'package:flutter/material.dart';

class ErrorCard extends StatelessWidget {
  final String title;
  final String text;
  const ErrorCard({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(kDefaultRadius),
          gradient: LinearGradient(
              colors: [
                kRedLightColor,
                kRedColor
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight
          )
      ),
      child: Stack(
        children: <Widget>[
          const Positioned(
            right: -10,
            bottom: -12,
            child: Icon(Icons.restore_rounded, color: Colors.white30, size: kLargeIconSize),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: semibold14WhiteStyle),
                Text(text, style: light12WhiteStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
