import 'package:aqromis_application/data/shared_prefs.dart';
import 'package:aqromis_application/screens/home.dart';
import 'package:aqromis_application/widgets/default_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aqromis_application/text_constants.dart' as constants;

import '../../constants.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _readLength = 5;
  bool _tipsValue = false;

  @override
  void initState() {
    getPrefs();
    super.initState();
  }

  getPrefs() async {
    await SharedData.getBool('tipsOpen')
        .then((value) => setState(() => _tipsValue = value ?? false));
    await SharedData.getInt('range')
        .then((value) => setState(() => _readLength = value ?? 5));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kInputFillColor,
      appBar: AppBar(
          title: const Text(constants.tSettings, style: semibold16Style)),
      body: Padding(
        padding: kSmallPadding,
        child: Column(
          children: <Widget>[
            Container(
              padding: kSmallPadding,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(kDefaultRadius),
                  color: kWhiteColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(constants.tReadLength, style: semibold16Style),
                  const Text(constants.tReadLengthDescription,
                      style: light14Style),
                  Slider(
                    min: 5,
                    max: 30,
                    divisions: 25,
                    value: _readLength.toDouble(),
                    onChanged: (value) =>
                        setState(() => _readLength = value.toInt()),
                    label: '$_readLength',
                    activeColor: kPrimaryColor,
                    inactiveColor: kPrimaryOpacityColor,
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: kSmallPadding,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(kDefaultRadius),
                  color: kWhiteColor),
              child: Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const <Widget>[
                      Text(constants.tOpenTips, style: semibold16Style),
                      Text(constants.tOpenTipsDescription, style: light14Style),
                    ],
                  ),
                  const Spacer(),
                  CupertinoSwitch(
                      value: _tipsValue,
                      activeColor: kPrimaryColor,
                      onChanged: (value) => setState(() => _tipsValue = value)),
                ],
              ),
            ),
            const Spacer(),
            DefaultButton(
              text: constants.tSave,
              textColor: kWhiteColor,
              backColor: kPrimaryColor,
              onPress: saveSettings,
            )
          ],
        ),
      ),
    );
  }

  saveSettings() async {
    SharedData.setBool('tipsOpen', _tipsValue);
    SharedData.setInt('range', _readLength);
    Navigator.pop(
        context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }
}
