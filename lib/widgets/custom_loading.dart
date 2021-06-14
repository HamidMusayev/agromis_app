import 'package:flutter/material.dart';

import '../constants.dart';

class CustomLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor), backgroundColor: kSecondaryColor);
  }
}
