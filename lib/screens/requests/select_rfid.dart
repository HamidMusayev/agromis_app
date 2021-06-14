import 'dart:io';

import 'package:aqromis_application/data/operations/rfid_operations.dart';
import 'package:aqromis_application/data/shared_prefs.dart';
import 'package:aqromis_application/models/request.dart';
import 'package:aqromis_application/models/rfid_garden_result.dart';
import 'package:aqromis_application/screens/requests/select_picture.dart';
import 'package:aqromis_application/screens/requests/select_tree.dart';
import 'package:aqromis_application/size_config.dart';
import 'package:aqromis_application/widgets/info_card.dart';
import 'package:flutter/material.dart';
import 'package:aqromis_application/text_constants.dart' as Constants;
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:soundpool/soundpool.dart';
import 'package:uhf_c72_plugin/tag_epc.dart';
import 'package:uhf_c72_plugin/uhf_c72_plugin.dart';

import '../../constants.dart';

class SelectRFIDScreen extends StatefulWidget {
  final Request request;
  SelectRFIDScreen(this.request);
  @override
  _SelectRFIDScreenState createState() => _SelectRFIDScreenState();
}

class _SelectRFIDScreenState extends State<SelectRFIDScreen> {
  TextEditingController rfidTxt = TextEditingController();
  String platformVersion = 'Unknown';
  bool tips = false;
  bool loading = false;

  List<TagEpc> data = [];
  Soundpool pool = Soundpool(streamType: StreamType.notification);

  @override
  void initState() {
    super.initState();
    getPrefs();
  }

  @override
  void dispose() {
    stopConnection();
    super.dispose();
  }

  getPrefs() async {
    await SharedData.getBool("tipsOpen").then((value) => setState(() => tips = value));
  }

  Future<void> stopConnection() async {
    await UhfC72Plugin.clearData;
    bool str = await UhfC72Plugin.isStarted;
    if(str){
      await UhfC72Plugin.stop;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Constants.tSelectAutomatic, style: semibold16Style),
      ),
      body: Column(
        children: <Widget>[
          tips != null && tips
              ? InfoCard(text: Constants.tInfo1Text)
              : Container(),
          Padding(
            padding: kSmallPadding,
            child: TextField(
                enabled: false,
                controller: rfidTxt,
                decoration: InputDecoration(hintText: Constants.tRFID)),
          ),
          loading
              ? Center(
                  child: Lottie.asset("assets/lottie/loading.json", width: getProportionateScreenWidth(200.0)))
              : Expanded(
                  child: Padding(
                    padding: kDefaultPadding,
                    child: FlatButton(
                      padding: kDefaultPadding,
                      color: kBlueOpacityColor,
                      splashColor: kWhiteColor,
                      highlightColor: Colors.transparent,
                      onPressed: () async {
                        data = [];
                        await UhfC72Plugin.clearData;
                        UhfC72Plugin.tagsStatusStream.receiveBroadcastStream().listen(updateTags);
                        await UhfC72Plugin.startSingle;
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(kDefaultRadius)),
                      child: Row(
                        children: <Widget>[
                          Spacer(),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.speaker_phone_rounded,
                                    size: getProportionateScreenHeight(100.0),
                                    color: kBlueColor),
                                Text(
                                  Constants.tRead,
                                  style: TextStyle(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w600,
                                      color: kBlueColor),
                                ),
                              ]),
                          Spacer()
                        ],
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Future<bool> _checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  void updateTags(dynamic result) {
    data = TagEpc.parseTags(result);
    getRFID(data);
  }

  Future<void> getRFID(List<TagEpc> data) async {

    if (data.isNotEmpty){
      playSound();
      setState(() => rfidTxt.text = data.first.epc.toString());
      setState(() => loading = true);

      _checkConnection().then((value) async {
        if(value){
          RFIDGardenResult result;
          await RFIDOperations.getGardenByRFID(rfidTxt.text).then((value) =>
          value != false ? result = value : showAlert(Constants.tCantFindRFIDNetworkError));

          if (result.isOneTree) {
            widget.request.isonetree = true;
            widget.request.epc = rfidTxt.text;
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SelectPictureScreen(request: widget.request)));
          }
          else {
            widget.request.isonetree = false;
            if (result.minTreeCount == 0 && result.maxTreeCount == 0) {
              showAlert(Constants.tCantFindRFIDxy);
            } else {
              widget.request.epc = rfidTxt.text;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SelectTreeScreen(gardenResult: result, request: widget.request)));
            }
          }
        }
        else{
          widget.request.isonetree = true;
          widget.request.epc = rfidTxt.text;

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SelectPictureScreen(request: widget.request)));
        }
      });
    }

    //bool isClosed = await UhfC72Plugin.close;
    //print('Close $isClosed');
    //bool isStopped = await UhfC72Plugin.stop;
    //print('Stop $isStopped');

    // bool isSetPower = await UhfC72Plugin.setPowerLevel(
    //     powerLevelController.text);
    //print('isSetPower $isSetPower');

    // bool isSetWorkArea = await UhfC72Plugin.setWorkArea(
    //     workAreaController.text);
    // print('isSetWorkArea $isSetWorkArea');
  }

  Future playSound() async{
    int soundId = await rootBundle.load("assets/sounds/success.wav").then((ByteData soundData) {
      return pool.load(soundData);
    });
    int streamId = await pool.play(soundId);
  }

  Future<dynamic> showAlert(String text) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black45,
      builder: (_) => AlertDialog(
        elevation: 0,
        titleTextStyle: semibold14Style,
        contentTextStyle: semibold14Style,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(kDefaultRadius)),
        title: Column(
          children: <Widget>[
            Icon(Icons.info, color: kBlueColor, size: 50.0),
            SizedBox(height: 12.0),
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
