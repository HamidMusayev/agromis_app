import 'package:aqromis_application/constants.dart';
import 'package:flutter/material.dart';

import '../size_config.dart';

class DefaultButton extends StatefulWidget {
  final String text;
  final Color backColor;
  final Color textColor;
  final Function onPress;
  DefaultButton({@required this.text, @required this.backColor, @required this.textColor, @required this.onPress});

  @override
  _DefaultButtonState createState() => _DefaultButtonState();
}

class _DefaultButtonState extends State<DefaultButton> {

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return FlatButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(kDefaultRadius)),
      color: widget.backColor,
      textColor: widget.textColor,
      height: getProportionateScreenHeight(70.0),
      child: Container(
        alignment: Alignment.center,
        child: Text(widget.text),
      ),
      onPressed: widget.onPress,
    );
  }
}
