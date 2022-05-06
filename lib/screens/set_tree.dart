import 'package:aqromis_application/data/operations/list.dart';
import 'package:aqromis_application/data/operations/rfid.dart';
import 'package:aqromis_application/models/add_tree/alan.dart';
import 'package:aqromis_application/models/add_tree/alan_rfid.dart';
import 'package:aqromis_application/models/add_tree/alandet.dart';
import 'package:aqromis_application/models/add_tree/bitkicesit.dart';
import 'package:aqromis_application/models/add_tree/bitkitur.dart';
import 'package:aqromis_application/models/garden.dart';
import 'package:flutter/material.dart';
import 'package:aqromis_application/text_constants.dart' as constants;
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';
import 'package:uhf_c72_plugin/tag_epc.dart';
import 'package:uhf_c72_plugin/uhf_c72_plugin.dart';

import '../constants.dart';

class SetTreeScreen extends StatefulWidget {
  const SetTreeScreen({Key? key}) : super(key: key);

  @override
  _SetTreeScreenState createState() => _SetTreeScreenState();
}

class _SetTreeScreenState extends State<SetTreeScreen> {
  TextEditingController rfidTxt = TextEditingController();
  String platformVersion = 'Unknown';
  bool _found = false;

  List<TagEpc> data = [];
  Soundpool pool = Soundpool.fromOptions(
      options: const SoundpoolOptions(streamType: StreamType.notification));

  List<Garden> _gardens = [];
  List<Alan> _alans = [];
  List<AlanDet> _alandets = [];
  List<BitkiCesit> _cesids = [];
  List<BitkiTur> _turs = [];

  Garden? _activeGarden;
  Alan? _activeAlan;
  AlanDet? _activeAlanDet;
  BitkiCesit? _activeCesit;
  BitkiTur? _activeTur;

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
    await ListOperations.getGardenList().then((value) => value != false
        ? setState(() => _gardens = value)
        : showAlert(constants.tCantFindRFIDNetworkError));
  }

  // Future<void> getDropDownData() async {
  //   await ListOperations.getAlanList().then((value) => value != false
  //       ? setState(() => _alans = value)
  //       : showAlert(Constants.tCantFindRFIDNetworkError));
  //
  //   await ListOperations.getBitkiCesitList().then((value) => value != false
  //       ? setState(() => _cesids = value)
  //       : showAlert(Constants.tCantFindRFIDNetworkError));
  // }

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
              TextField(
                  controller: rfidTxt,
                  enabled: false,
                  decoration: const InputDecoration(hintText: constants.tRFID)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: const BorderRadius.all(kDefaultRadius)),
                child: DropdownButton<Garden>(
                  value: _activeGarden,
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  iconSize: 30,
                  isExpanded: true,
                  hint: const Text('Bağ seçin'),
                  underline: Container(),
                  onChanged: (val) async => await gardenChanged(val),
                  items: _gardens.map((val) {
                    return DropdownMenuItem<Garden>(
                      value: val,
                      child: Text(val.pin.toString() + '-' + val.name),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
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
                  onChanged: (val) async => await alanChanged(val),
                  items: _alans.map((val) {
                    return DropdownMenuItem<Alan>(
                      value: val,
                      child: ListTile(
                        title: Text(val.pin + '-' + val.alanname),
                        subtitle: Text(val.rfid),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: const BorderRadius.all(kDefaultRadius)),
                child: DropdownButton<AlanDet>(
                  value: _activeAlanDet,
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  iconSize: 30,
                  isExpanded: true,
                  hint: const Text('Ağac seçin'),
                  underline: Container(),
                  onChanged: (val) async => await alanDetChanged(val),
                  items: _alandets.map((val) {
                    return DropdownMenuItem<AlanDet>(
                      value: val,
                      child: ListTile(
                        title: Text('PIN_ALANDET-' +
                            val.pin +
                            ' / PINABITKI-' +
                            val.pinabitki),
                        subtitle: Text(val.epc),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: const BorderRadius.all(kDefaultRadius)),
                child: DropdownButton<BitkiCesit>(
                  value: _activeCesit,
                  isExpanded: true,
                  hint: const Text('Bitki Çeşidi seçin'),
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  iconSize: 30,
                  underline: Container(),
                  onChanged: (cesid) => setState(() => _activeCesit = cesid),
                  items: _cesids.map((cesid) {
                    return DropdownMenuItem<BitkiCesit>(
                      value: cesid,
                      child: Text(cesid.cesitname),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: const BorderRadius.all(kDefaultRadius)),
                child: DropdownButton<BitkiTur>(
                  value: _activeTur,
                  isExpanded: true,
                  hint: const Text('Bitki Növü seçin'),
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  iconSize: 30,
                  underline: Container(),
                  onChanged: (val) => setState(() => _activeTur = val),
                  items: _turs.map((tur) {
                    return DropdownMenuItem<BitkiTur>(
                      value: tur,
                      child: Text(tur.turname),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              _found
                  ? Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: kSmallPadding,
                          backgroundColor: kGreenColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(kDefaultRadius),
                          ),
                        ),
                        onPressed: () async => saveAlanRFID(),
                        child: Row(
                          children: <Widget>[
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const <Widget>[
                                Icon(Icons.check_rounded,
                                    size: 70, color: Colors.white),
                                Text(
                                  constants.tSave,
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            const Spacer()
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: kSmallPadding,
                          backgroundColor: kBlueColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(kDefaultRadius),
                          ),
                        ),
                        onPressed: () async {
                          data.clear();
                          await UhfC72Plugin.clearData;
                          UhfC72Plugin.tagsStatusStream
                              .receiveBroadcastStream()
                              .listen(updateTags);
                          await UhfC72Plugin.startSingle;
                        },
                        child: Row(
                          children: <Widget>[
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const <Widget>[
                                Icon(Icons.speaker_phone_rounded,
                                    size: 70, color: Colors.white),
                                Text(
                                  constants.tRead,
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              ],
                            ),
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
        .load('assets/sounds/barcodebeep.ogg')
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
    } else if (_activeGarden == null) {
      showAlert('Bağ seçilməyib!');
    } else if (_activeAlan == null) {
      showAlert('Sıra seçilməyib!');
    } else if (_activeAlanDet == null) {
      showAlert('Cərgə seçilməyib!');
    } else if (_activeCesit == null) {
      showAlert('Çeşid seçilməyib!');
    } else if (_activeTur == null) {
      showAlert('Növ seçilməyib!');
    } else {
      RFIDOperations.saveAlanRFID(
        AlanRFID(
          rfidTxt.text,
          _activeAlanDet!.pinabitki,
          _activeTur!.pin,
          _activeCesit!.pin,
        ),
      ).then((value) {
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
      _activeCesit = null;
      _activeTur = null;
      _activeGarden = null;
      _activeAlanDet = null;
      _activeAlan = null;
    });
  }

  gardenChanged(Garden? val) async {
    _activeGarden = val;

    await ListOperations.getAlanList(_activeGarden!.pin.toString()).then(
        (value) => value != false
            ? setState(() => _alans = value)
            : showAlert(constants.tCantFindRFIDNetworkError));
  }

  alanChanged(Alan? val) async {
    _activeAlan = val;

    await ListOperations.getAlanDetList(_activeAlan!.pin.toString()).then(
        (value) => value != false
            ? setState(() => _alandets = value)
            : showAlert(constants.tCantFindRFIDNetworkError));
  }

  alanDetChanged(AlanDet? val) async {
    _activeAlanDet = val;

    await ListOperations.getBitkiCesitList().then((value) => value != false
        ? setState(() => _cesids = value)
        : showAlert(constants.tCantFindRFIDNetworkError));

    await ListOperations.getBitkiTurList().then((value) => value != false
        ? setState(() => _turs = value)
        : showAlert(constants.tCantFindRFIDNetworkError));
  }
}
