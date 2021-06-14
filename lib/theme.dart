import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'constants.dart';

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: kPrimaryColor,
    fontFamily: "segoeui",
    appBarTheme: appBarTheme(),
    textTheme: textTheme(),
    inputDecorationTheme: inputDecorationTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

InputDecorationTheme inputDecorationTheme() {
  OutlineInputBorder outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: BorderSide(color: Colors.transparent)
  );

  OutlineInputBorder errorInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: BorderSide(color: kRedColor)
  );

  return InputDecorationTheme(
    floatingLabelBehavior: FloatingLabelBehavior.always,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    enabledBorder: outlineInputBorder,
    focusedBorder: outlineInputBorder,
    filled: true,
    fillColor: kInputFillColor,
    border: outlineInputBorder,
    labelStyle: TextStyle(color: kInputTextColor),
    errorStyle: TextStyle(color: kRedColor),
    errorBorder: errorInputBorder
  );
}

TextTheme textTheme() {
  return TextTheme(
    button: buttonStyle,
  );
}

AppBarTheme appBarTheme() {
  return AppBarTheme(
    color: Colors.white,
    elevation: 0,
    brightness: Brightness.light,
    iconTheme: IconThemeData(color: kTextColor),
    textTheme: TextTheme(headline6: TextStyle(color: kTextColor, fontSize: 18)),
  );
}