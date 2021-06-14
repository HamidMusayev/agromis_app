import 'package:flutter/material.dart';

import '../constants.dart';
import '../size_config.dart';

class DefaultCard extends StatelessWidget {
  final Color color;
  final Color lightColor;
  final bool selected;
  final Function onPress;
  final IconData icon;
  final String text;
  DefaultCard({this.color, this.lightColor, this.onPress, this.icon, this.text, this.selected});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return FlatButton(
      color: lightColor,
      splashColor: Colors.transparent,
      highlightColor: color.withOpacity(0.4),
      onPressed: onPress,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(kDefaultRadius),
      ),
      child: Row(
        children: <Widget>[
          Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? kWhiteColor : color, size: getProportionateScreenHeight(75.0)),
              Text(text, style: TextStyle(fontSize: 16.0, color: selected ? kWhiteColor : color)),
            ],
          ),
          Spacer()
        ],
      ),
    );
  }
}
