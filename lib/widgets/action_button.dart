import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../constants.dart';

class ActionButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final bool loading;
  final String text;
  final Function onPress;

  const ActionButton(
      {required this.color,
      required this.icon,
      required this.loading,
      required this.text,
      required this.onPress});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(kDefaultRadius),
          gradient: LinearGradient(
              colors: [color, color.withAlpha(80)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: kDefaultPadding,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(kDefaultRadius),
          ),
        ),
        child: Row(
          children: <Widget>[
            const Spacer(),
            loading
                ? Center(
                    child: Lottie.asset(
                        'assets/lottie/loading_blink_white.json',
                        width: 90))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(icon, color: kWhiteColor, size: 60.0),
                      Text(text,
                          style:
                              const TextStyle(color: kWhiteColor, fontSize: 16))
                    ],
                  ),
            const Spacer()
          ],
        ),
        onPressed: () => onPress.call(),
      ),
    );
  }
}
