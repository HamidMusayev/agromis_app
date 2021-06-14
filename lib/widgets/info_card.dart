import 'package:aqromis_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:aqromis_application/text_constants.dart' as Constants;

class InfoCard extends StatelessWidget {
  final String text;
  InfoCard({this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: kSmallPadding,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(kDefaultRadius),
          gradient: LinearGradient(
              colors: [
                kBlueLightColor,
                kBlueColor
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight
          )
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -10,
            bottom: -12,
            child: Icon(Icons.help_outline_rounded, color: Colors.white30, size: kLargeIconSize),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(Constants.tInfoTitle, style: semibold14WhiteStyle),
                    Text(text, style: light12WhiteStyle),
                  ],
                ),
                Spacer()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
