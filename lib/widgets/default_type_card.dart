import 'package:flutter/material.dart';

import '../constants.dart';

class DefaultTypeCard extends StatelessWidget {
  final Color color;
  final Color lightColor;
  final bool selected;
  final Function onPress;
  final IconData icon;
  final String text;
  const DefaultTypeCard({required this.color, required this.lightColor, required this.onPress, required this.icon, required this.text, required this.selected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>onPress.call(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(kDefaultRadius),
          color: selected ? color : lightColor,
        ),
        child: Row(
          children: <Widget>[
            const Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, color: selected ? kWhiteColor : color, size: 75),
                Text(text, style: TextStyle(fontSize: 16.0, color: selected ? kWhiteColor : color)),
              ],
            ),
            const Spacer()
          ],
        ),
      ),
    );
  }
}
