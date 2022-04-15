import 'package:aqromis_application/data/operations/list_operations.dart';
import 'package:aqromis_application/data/operations/rfid_operations.dart';
import 'package:aqromis_application/models/add_tree/alan.dart';
import 'package:aqromis_application/models/add_tree/alan_rfid.dart';
import 'package:aqromis_application/models/add_tree/bitkicesit.dart';
import 'package:flutter/material.dart';
import 'package:aqromis_application/text_constants.dart' as Constants;
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';
import 'package:uhf_c72_plugin/tag_epc.dart';
import 'package:uhf_c72_plugin/uhf_c72_plugin.dart';

import '../../constants.dart';

class SetTreeScreen extends StatefulWidget {
  @override
  _SetTreeScreenState createState() => _SetTreeScreenState();
}

class _SetTreeScreenState extends State<SetTreeScreen> {
  TextEditingController rfidTxt = TextEditingController();
  String platformVersion = 'Unknown';
  bool _found = false;

  List<TagEpc> data = [];
  Soundpool pool = Soundpool(streamType: StreamType.notification);

  List<Alan> _alans = [];
  List<BitkiCesid> _cesids = [];
  Alan? _activeAlan;
  BitkiCesid? _activeCesid;

  @override
  void initState() {
    getDropDownData();
    super.initState();
  }

  @override
  void dispose() {
    stopConnection();
    super.dispose();
  }

  Future<void> stopConnection() async {
    await UhfC72Plugin.clearData;
    bool? str = await UhfC72Plugin.isStarted;
    if (str ?? false) {
      await UhfC72Plugin.stop;
    }
  }

  Future<void> getDropDownData() async {
    await ListOperations.getAlanList().then((value) => value != false
        ? setState(() => _alans = value)
        : showAlert(Constants.tCantFindRFIDNetworkError));

    await ListOperations.getBitkiCesidList().then((value) => value != false
        ? setState(() => _cesids = value)
        : showAlert(Constants.tCantFindRFIDNetworkError));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Etiket tanıtma',
            style: TextStyle(color: Colors.black, fontSize: 17)),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
              onPressed: () => reset(),
              child: const Text('Sıfırla', style: TextStyle(color: Colors.red)))
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: kSmallPadding,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: TextField(
                    controller: rfidTxt,
                    enabled: false,
                    decoration:
                        const InputDecoration(hintText: Constants.tRFID)),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: const BorderRadius.all(kDefaultRadius)),
                child: DropdownButton<Alan>(
                  value: _activeAlan,
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  iconSize: 30,
                  isExpanded: true,
                  hint: const Text('Sıra seçin'),
                  underline: Container(),
                  onChanged: (alan) {
                    _activeAlan = alan;
                    for (BitkiCesid cesid in _cesids) {
                      if (cesid.pin == _activeAlan?.pinbitkicesid) {
                        _activeCesid = cesid;
                      }
                    }
                    setState(() {});
                  },
                  items: _alans.map((alan) {
                    return DropdownMenuItem<Alan>(
                        value: alan,
                        child: Row(
                          children: [
                            Text(alan.pin + '-' + alan.alanname),
                            const Spacer(),
                            Text(alan.rfid),
                          ],
                        ));
                  }).toList(),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: const BorderRadius.all(kDefaultRadius)),
                child: DropdownButton<BitkiCesid>(
                  value: _activeCesid,
                  isExpanded: true,
                  hint: const Text('Bitki Növü seçin'),
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  iconSize: 30,
                  underline: Container(),
                  onChanged: (cesid) => setState(() => _activeCesid = cesid),
                  items: _cesids.map((cesid) {
                    return DropdownMenuItem<BitkiCesid>(
                        value: cesid, child: Text(cesid.cesidname));
                  }).toList(),
                ),
              ),
              _found
                  ? Expanded(
                      child: FlatButton(
                        padding: kSmallPadding,
                        color: kGreenColor,
                        onPressed: () {
                          saveAlanRFID();
                        },
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(kDefaultRadius)),
                        child: Row(
                          children: <Widget>[
                            const Spacer(),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const <Widget>[
                                  Icon(Icons.check_rounded,
                                      size: 100, color: Colors.white),
                                  Text(
                                    Constants.tSave,
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                ]),
                            const Spacer()
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: FlatButton(
                        padding: kSmallPadding,
                        color: kBlueColor,
                        onPressed: () async {
                          data = [];
                          await UhfC72Plugin.clearData;
                          UhfC72Plugin.tagsStatusStream
                              .receiveBroadcastStream()
                              .listen(updateTags);
                          await UhfC72Plugin.startSingle;
                        },
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(kDefaultRadius)),
                        child: Row(
                          children: <Widget>[
                            const Spacer(),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const <Widget>[
                                  Icon(Icons.speaker_phone_rounded,
                                      size: 100, color: Colors.white),
                                  Text(
                                    Constants.tRead,
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                ]),
                            const Spacer()
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void updateTags(dynamic result) {
    data = TagEpc.parseTags(result);
    getRFID(data);
  }

  Future<void> getRFID(List<TagEpc> data) async {
    if (data.isNotEmpty) {
      playSound();
      setState(() {
        rfidTxt.text = data.first.epc.toString();
        _found = true;
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

  Future playSound() async {
    int soundId = await rootBundle
        .load('assets/sounds/success.wav')
        .then((ByteData soundData) {
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
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(kDefaultRadius)),
        title: Column(
          children: <Widget>[
            const Icon(Icons.info, color: kBlueColor, size: 50.0),
            const SizedBox(height: 12.0),
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  void saveAlanRFID() {
    if (rfidTxt.text.isEmpty) {
      showAlert('RFID Boşdur!');
    } else if (_activeAlan == null) {
      showAlert('Sıra seçilməyib!');
    } else if (_activeCesid == null) {
      showAlert('Bitki növü seçilməyib!');
    } else {
      RFIDOperations.saveAlanRFID(
              AlanRFID(rfidTxt.text, _activeAlan!.pin, _activeCesid!.pin))
          .then((value) {
        if (value == 'true') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                  'Yadda saxlanıldı! - ${rfidTxt.text} / ${_activeAlan!.alanname}')));
          reset();
        } else {
          showAlert(value);
        }
      });
    }
  }

  void reset() {
    setState(() {
      _found = false;
      rfidTxt.clear();
      _activeCesid = null;
      _activeAlan = null;
    });
  }
}
