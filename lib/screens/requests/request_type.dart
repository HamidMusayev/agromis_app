import 'dart:async';

import 'package:aqromis_application/data/operations/list_operations.dart';
import 'package:aqromis_application/models/agronom.dart';
import 'package:aqromis_application/models/request.dart';
import 'package:aqromis_application/screens/requests/select_rfid.dart';
import 'package:aqromis_application/widgets/default_button.dart';
import 'package:aqromis_application/widgets/default_type_card.dart';
import 'package:aqromis_application/widgets/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:aqromis_application/text_constants.dart' as Constants;
import 'package:uhf_c72_plugin/uhf_c72_plugin.dart';
import '../../constants.dart';

class RequestTypeScreen extends StatefulWidget {
  @override
  _RequestTypeScreenState createState() => _RequestTypeScreenState();
}

class _RequestTypeScreenState extends State<RequestTypeScreen> {
  Agronom? _selectedItem;
  Request request = Request(description: '', pictures: [], epc: '', title: '', selectedtrees: [], infotype: 0, createusercode: 0, isonetree: false, isselectedall: false);
  List<Agronom> agronoms = [];
  bool loading = true;
  final List<bool> _types = [false, false, false, false];

  @override
  void initState() {
    getAgronoms();
    super.initState();
  }

  getAgronoms() async {
    await ListOperations.getAgronomList()
        .then((value) => value != false ? setState(() => agronoms = value) : null)
        .then((value) => setState(() => loading = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Constants.tSelectType, style: semibold16Style),
      ),
      body: Padding(
        padding: kSmallPadding,
        child: Column(
          children: <Widget>[
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12.0,
                crossAxisSpacing: 12.0,
                children: <Widget>[
                  DefaultTypeCard(
                    color: kGreenColor,
                    lightColor: kGreenOpacityColor,
                    selected: _types[0],
                    icon: Icons.contact_support,
                    text: Constants.tTypeQuestion,
                    onPress: () {
                      setState(() {
                        _types[0] = !_types[0];
                        _types[1] = false;
                        _types[2] = false;
                        _types[3] = false;
                      });
                    },
                  ),
                  DefaultTypeCard(
                    color: kBlueColor,
                    lightColor: kBlueOpacityColor,
                    selected: _types[1],
                    icon: Icons.info_rounded,
                    text: Constants.tTypeInfo,
                    onPress: () {
                      setState(() {
                        _types[1] = !_types[1];
                        _types[0] = false;
                        _types[2] = false;
                        _types[3] = false;
                      });
                    },
                  ),
                  DefaultTypeCard(
                    color: kRedColor,
                    lightColor: kRedOpacityColor,
                    selected: _types[2],
                    icon: Icons.bug_report_rounded,
                    text: Constants.tTypeDisease,
                    onPress: () {
                      setState(() {
                        _types[2] = !_types[2];
                        _types[1] = false;
                        _types[0] = false;
                        _types[3] = false;
                      });
                    },
                  ),
                  DefaultTypeCard(
                    color: kYellowColor,
                    lightColor: kYellowOpacityColor,
                    selected: _types[3],
                    icon: Icons.textsms_rounded,
                    text: Constants.tTypeRequest,
                    onPress: () {
                      setState(() {
                        _types[3] = !_types[3];
                        _types[1] = false;
                        _types[2] = false;
                        _types[0] = false;
                      });
                    },
                  )
                ],
              ),
            ),
            loading
                ? CustomLoading()
                : Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 4.0),
                    decoration: const BoxDecoration(
                        color: kInputFillColor,
                        borderRadius: BorderRadius.all(kDefaultRadius)),
                    child: DropdownButton<Agronom>(
                      isExpanded: true,
                      hint: const Text(Constants.tGardenerSelect),
                      value: _selectedItem,
                      icon: const Icon(Icons.arrow_drop_down_rounded),
                      iconSize: kDefaultIconSize,
                      elevation: 2,
                      underline: const SizedBox(),
                      onChanged: (Agronom? value) {
                        setState(() => _selectedItem = value);
                      },
                      items: agronoms
                          .map<DropdownMenuItem<Agronom>>((Agronom value) {
                        return DropdownMenuItem<Agronom>(
                          value: value,
                          child: Text(value.name),
                        );
                      }).toList(),
                    ),
                  ),
            const SizedBox(height: 20.0),
            DefaultButton(
              text: Constants.tNext,
              textColor: kWhiteColor,
              backColor: kPrimaryColor,
              onPress: () {
                if (_types[0] || _types[1] || _types[2] || _types[3]) {
                  if(_types[0]){
                    request.infotype = 3;
                  }
                  else if (_types[1]){
                    request.infotype = 1;
                  }
                  else if (_types[2]){
                    request.infotype = 2;
                  }
                  else{
                    request.infotype = 4;
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SelectRFIDScreen(request))).then(onGoBack);
                } else {
                  showAlert().timeout(const Duration(seconds: 3),
                      onTimeout: () => Navigator.pop(context));
                }
              },
            )
          ],
        ),
      ),
    );
  }

  FutureOr onGoBack(dynamic value) {
    stopConnection();
  }

  Future<void> stopConnection() async {
    bool? cnn = await UhfC72Plugin.isConnected;
    if(cnn??false){
      await UhfC72Plugin.clearData;
    }
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
            Icon(Icons.info, color: kBlueColor, size: 50.0),
            SizedBox(height: 12.0),
            Text(Constants.tAlertSelectType, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
