import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: kPrimaryColor,
    fontFamily: 'segoeui',
    appBarTheme: appBarTheme(),
    textTheme: textTheme(),
    inputDecorationTheme: inputDecorationTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

InputDecorationTheme inputDecorationTheme() {
  OutlineInputBorder outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: const BorderSide(color: Colors.transparent));

  OutlineInputBorder errorInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: const BorderSide(color: kRedColor));

  return InputDecorationTheme(
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: outlineInputBorder,
      focusedBorder: outlineInputBorder,
      filled: true,
      fillColor: kInputFillColor,
      border: outlineInputBorder,
      labelStyle: const TextStyle(color: kInputTextColor),
      errorStyle: const TextStyle(color: kRedColor),
      errorBorder: errorInputBorder);
}

TextTheme textTheme() {
  return const TextTheme(
    button: buttonStyle,
  );
}

AppBarTheme appBarTheme() {
  return AppBarTheme(
    color: Colors.white,
    elevation: 0,
    iconTheme: const IconThemeData(color: kTextColor),
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    toolbarTextStyle:
        const TextTheme(headline6: TextStyle(color: kTextColor, fontSize: 18))
            .bodyText2,
    titleTextStyle:
        const TextTheme(headline6: TextStyle(color: kTextColor, fontSize: 18))
            .headline6,
  );
}
