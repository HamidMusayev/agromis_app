import 'package:aqromis_application/data/shared_prefs.dart';
import 'package:aqromis_application/models/request.dart';
import 'package:aqromis_application/models/rfid_garden_result.dart';
import 'package:aqromis_application/screens/requests/select_picture.dart';
import 'package:aqromis_application/utils/text_validators.dart';
import 'package:aqromis_application/widgets/default_button.dart';
import 'package:aqromis_application/widgets/info_card.dart';
import 'package:flutter/material.dart';
import 'package:aqromis_application/text_constants.dart' as Constants;
import 'package:flutter/services.dart';

import '../../constants.dart';

class SelectTreeScreen extends StatefulWidget {
  final RFIDGardenResult? gardenResult;
  final Request? request;
  const SelectTreeScreen({this.gardenResult, this.request});

  @override
  _SelectTreeScreenState createState() => _SelectTreeScreenState();
}

class _SelectTreeScreenState extends State<SelectTreeScreen> {
  TextEditingController numberTxt = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isSelectedAll = false;
  List<int> trees = [];
  bool tips = false;

  @override
  void initState() {
    getPrefs();
    super.initState();
  }

  getPrefs() async {
    await SharedData.getBool('tipsOpen')
        .then((value) => setState(() => tips = value ?? false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(Constants.tSelectTree, style: semibold16Style)),
      body: Column(
        children: <Widget>[
          tips ? const InfoCard(text: Constants.tInfo2Text) : Container(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(Constants.tSelectedTrees, style: semibold16Style),
                const Spacer(),
                Checkbox(
                    value: isSelectedAll,
                    activeColor: kPrimaryColor,
                    onChanged: (value) =>
                        setState(() => isSelectedAll = value ?? false)),
                const Text(Constants.tSelectAll, style: semibold14Style),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: kSmallPadding,
                child: Wrap(
                  spacing: 6.0,
                  children: <Widget>[
                    ...trees.map(
                      (int number) => Chip(
                        labelPadding: const EdgeInsets.all(3.0),
                        deleteIcon: const Icon(Icons.cancel, size: 28.0),
                        deleteIconColor: kRedLightColor,
                        onDeleted: () => setState(() => trees.remove(number)),
                        backgroundColor: kInputFillColor,
                        label: Text(number.toString(),
                            style: const TextStyle(fontSize: 18.0)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: kSmallPadding,
            child: Row(
              children: <Widget>[
                DefaultButton(
                  text: 'Əlavə et',
                  textColor: kPrimaryColor,
                  backColor: kSecondaryColor,
                  onPress: () {
                    return showDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierColor: Colors.black45,
                      builder: (_) => SingleChildScrollView(
                        child: AlertDialog(
                          titlePadding: const EdgeInsets.all(0),
                          elevation: 0,
                          titleTextStyle: semibold14Style,
                          contentTextStyle: semibold14Style,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(kDefaultRadius),
                          ),
                          title: Column(
                            children: <Widget>[
                              Padding(
                                padding: kDefaultPadding,
                                child: Form(
                                  key: formKey,
                                  child: TextFormField(
                                    autofocus: true,
                                    controller: numberTxt,
                                    validator: (val) => TextValidator()
                                        .validateTreeCount(
                                            val!,
                                            widget.gardenResult!.minTreeCount,
                                            widget.gardenResult!.maxTreeCount),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: Constants.tSelectNumber,
                                      prefixIcon: Icon(Icons.park),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: kInputTextColor,
                                              width: 1.5)),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: kPrimaryColor,
                                              width: 1.5)),
                                      fillColor: kWhiteColor,
                                    ),
                                  ),
                                ),
                              ),
                              DefaultButton(
                                onPress: () {
                                  if (numberTxt.text.trim().isNotEmpty) {
                                    if (formKey.currentState?.validate() ??
                                        false) {
                                      Navigator.pop(context);
                                      setState(() {
                                        trees.add(int.parse(numberTxt.text));
                                        numberTxt.clear();
                                      });
                                    }
                                  }
                                },
                                backColor: kSecondaryColor,
                                textColor: kPrimaryColor,
                                text: Constants.tSave,
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: DefaultButton(
                    text: Constants.tNext,
                    textColor: kWhiteColor,
                    backColor: kPrimaryColor,
                    onPress: () {
                      trees.isEmpty && isSelectedAll == false
                          ? showAlert().timeout(const Duration(seconds: 2),
                              onTimeout: () => Navigator.pop(context))
                          : goToPictureScreen();
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<dynamic> showAlert() {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black45,
      builder: (_) => AlertDialog(
        elevation: 0,
        titleTextStyle: semibold14Style,
        contentTextStyle: semibold14Style,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(kDefaultRadius)),
        title: Column(
          children: const <Widget>[
            Icon(Icons.park, color: kRedColor, size: 50.0),
            SizedBox(height: 12.0),
            Text(Constants.tNotSelected, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  goToPictureScreen() {
    isSelectedAll
        ? widget.request!.isselectedall = isSelectedAll
        : widget.request!.selectedtrees = trees;
    widget.request!.isselectedall = false;

    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SelectPictureScreen(request: widget.request!)));
  }
}
