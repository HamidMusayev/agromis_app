import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFF12CCCE);
const kPrimaryLightColor = Color(0xFF14DDDF);
const kSecondaryColor = Color(0xFFDCFBFB);
const kDarkColor = Color(0xFF31394A);

const kTextColor = Color(0xFF424852);
const kLightTextColor = Color(0xFFB7B7B7);

const kWhiteColor = Color(0xFFFFFFFF);
const kLightWhiteColor = Color(0xFFFFFFFF);
const kRedColor = Color(0xFFEB5463);
const kRedLightColor = Color(0xFFF76C82);
const kGreenColor = Color(0xFF9ED26A);
const kGreenLightColor = Color(0xFFB4DF80);
const kBlueColor = Color(0xFF4FC0E8);
const kBlueLightColor = Color(0xFF66D4F1);
const kYellowColor = Color(0xFFFDCD56);
const kYellowLightColor = Color(0xFFFBD277);

const kPrimaryOpacityColor = Color(0xFFE7FAF5);
const kGreenOpacityColor = Color(0xFFF1F8E9);
const kRedOpacityColor = Color(0xFFFCE5E8);
const kBlueOpacityColor = Color(0xFFE5F6FC);
const kYellowOpacityColor = Color(0xFFFFF8E6);

const kInputFillColor = Color(0xFFF5F5F5);
const kInputTextColor = Color(0xFFCFD2D4);

const kDefaultPadding = EdgeInsets.all(16.0);
const kSmallPadding = EdgeInsets.all(12.0);
const kDefaultRadius = Radius.circular(15.0);
const kDefaultIconSize = 30.0;
const kLargeIconSize = 90.0;

const headingStyle = TextStyle(fontSize: 30.0, fontWeight: FontWeight.w700, color: kTextColor);
const headingWhiteStyle = TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700, color: kWhiteColor);
const buttonStyle = TextStyle(color: kTextColor, fontSize: 16, fontWeight: FontWeight.w600);
const semibold14WhiteStyle = TextStyle(color: kWhiteColor, fontSize: 14, fontWeight: FontWeight.w600);
const semibold14PrimaryStyle = TextStyle(color: kPrimaryColor, fontSize: 14, fontWeight: FontWeight.w600);
const semibold16WhiteStyle = TextStyle(color: kWhiteColor, fontSize: 16, fontWeight: FontWeight.w600);
const light12WhiteStyle = TextStyle(color: kWhiteColor, fontSize: 12, fontWeight: FontWeight.w400);
const light14WhiteStyle = TextStyle(color: kWhiteColor, fontSize: 14, fontWeight: FontWeight.w400);
const light16WhiteStyle = TextStyle(color: kWhiteColor, fontSize: 16, fontWeight: FontWeight.w400);
const semibold14Style = TextStyle(color: kTextColor, fontSize: 14, fontWeight: FontWeight.w600);
const semibold16Style = TextStyle(color: kTextColor, fontSize: 16, fontWeight: FontWeight.w600);
const light14Style = TextStyle(color: kLightTextColor, fontSize: 14, fontWeight: FontWeight.w400);
const rfidStyle =TextStyle(fontSize: 48.0,fontWeight: FontWeight.w700,color: kWhiteColor);

final RegExp emailValidatorRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');

const kAnimationDuration = Duration(milliseconds: 1000);
