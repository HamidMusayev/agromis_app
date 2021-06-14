import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../constants.dart';
import '../size_config.dart';

class ActionButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final bool loading;
  final String text;
  final Function onPress;

  ActionButton({this.color, this.icon, this.loading, this.text, this.onPress});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(kDefaultRadius),
        gradient: LinearGradient(colors: [color, color.withAlpha(80)], begin: Alignment.topLeft, end: Alignment.bottomRight)
      ),
      child: FlatButton(
          padding: kDefaultPadding,
          splashColor: Colors.transparent,
          highlightColor: color.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(kDefaultRadius)),
          child: Row(
            children: <Widget>[
              Spacer(),
              loading ? Center(child: Lottie.asset("assets/lottie/loading_blink_white.json", width: getProportionateScreenWidth(90.0))) : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(icon, color: kWhiteColor, size: 60.0),
                  Text(text, style: TextStyle(color: kWhiteColor, fontSize: 16))
                ],
              ),
              Spacer()
            ],
          ),
          onPressed: onPress),
    );
  }
}
