import 'dart:io';

import 'package:flutter/material.dart';
import 'package:aqromis_application/text_constants.dart' as Constants;

import '../constants.dart';

class PictureHolder extends StatefulWidget {
  final String path;
  final Function onPress;
  PictureHolder(this.path, this.onPress);

  @override
  _PictureHolderState createState() => _PictureHolderState();
}

class _PictureHolderState extends State<PictureHolder> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.path.isNotEmpty
            ? ClipRRect(
                child: Image.file(File(widget.path)),
                borderRadius: BorderRadius.all(Radius.circular(5.0)))
            : Container(
                child: Center(
                    child: Text(Constants.tEmpty,
                        style: TextStyle(color: kInputTextColor))),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(kDefaultRadius),
                    color: kInputFillColor)),
        Align(
          alignment: Alignment.topRight,
          child: GestureDetector(
            onTap: widget.onPress,
            child: Container(
              height: 24.0,
              width: 28.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  color: kRedLightColor),
              child: Icon(
                Icons.remove_rounded,
                color: kWhiteColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
