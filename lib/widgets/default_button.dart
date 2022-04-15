import 'package:aqromis_application/constants.dart';
import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  final String text;
  final Color backColor;
  final Color textColor;
  final Function onPress;
  const DefaultButton(
      {Key? key,
      required this.text,
      required this.backColor,
      required this.textColor,
      required this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: backColor,
        primary: textColor,
        fixedSize: const Size(double.maxFinite, 60),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(kDefaultRadius),
        ),
      ),
      child: Text(text),
      onPressed: () => onPress.call(),
    );
  }
}
