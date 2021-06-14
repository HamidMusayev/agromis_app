import 'package:flutter/material.dart';

import '../constants.dart';
import '../size_config.dart';

class DefaultTypeCard extends StatelessWidget {
  final Color color;
  final Color lightColor;
  final bool selected;
  final Function onPress;
  final IconData icon;
  final String text;
  DefaultTypeCard({this.color, this.lightColor, this.onPress, this.icon, this.text, this.selected});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return GestureDetector(
      onTap: onPress,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(kDefaultRadius),
          color: selected ? color : lightColor,
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
      ),
    );
  }
}
