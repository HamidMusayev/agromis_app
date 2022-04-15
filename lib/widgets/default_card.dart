import 'package:flutter/material.dart';

import '../constants.dart';

class DefaultCard extends StatelessWidget {
  final Color color;
  final Color lightColor;
  final bool selected;
  final Function onPress;
  final IconData icon;
  final String text;
  const DefaultCard(
      {required this.color,
      required this.lightColor,
      required this.onPress,
      required this.icon,
      required this.text,
      required this.selected});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: lightColor,
      splashColor: Colors.transparent,
      highlightColor: color.withOpacity(0.4),
      onPressed: ()=> onPress.call(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(kDefaultRadius),
      ),
      child: Row(
        children: <Widget>[
          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon,
                  color: selected ? kWhiteColor : color,
                  size: 75),
              Text(text,
                  style: TextStyle(
                      fontSize: 16.0, color: selected ? kWhiteColor : color)),
            ],
          ),
          const Spacer()
        ],
      ),
    );
  }
}
