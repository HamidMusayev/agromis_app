import 'package:aqromis_application/constants.dart';
import 'package:aqromis_application/screens/treeinfo/tree_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';
import 'package:uhf_c72_plugin/tag_epc.dart';
import 'package:uhf_c72_plugin/uhf_c72_plugin.dart';
import 'package:aqromis_application/text_constants.dart' as constants;

import '../../data/operations/list.dart';
import '../../models/add_tree/alan.dart';
import '../../models/add_tree/alandet.dart';
import '../../models/garden.dart';

class PickTreeScreen extends StatefulWidget {
  const PickTreeScreen({Key? key}) : super(key: key);

  @override
  State<PickTreeScreen> createState() => _PickTreeScreenState();
}

class _PickTreeScreenState extends State<PickTreeScreen> {
  TextEditingController rfidTxt = TextEditingController();
  String platformVersion = 'Unknown';
  bool _found = false;

  List<TagEpc> data = [];
  Soundpool pool = Soundpool.fromOptions(
      options: const SoundpoolOptions(streamType: StreamType.notification));

  List<Garden> _gardens = [];
  List<Alan> _alans = [];
  List<AlanDet> _alandets = [];

  Garden? _activeGarden;
  Alan? _activeAlan;
  AlanDet? _activeAlanDet;

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

    setState(() => _found = true);
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

  void reset() {
    setState(() {
      _found = false;
      rfidTxt.clear();
      _activeGarden = null;
      _activeAlanDet = null;
      _activeAlan = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Ağac seçimi',
            style: TextStyle(color: Colors.black, fontSize: 17)),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
              onPressed: () => reset(),
              child: const Text('Sıfırla', style: TextStyle(color: Colors.red)))
        ],
      ),
      body: Padding(
        padding: kSmallPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Əl ilə seçin:', style: semibold16Style),
            const SizedBox(height: 10),
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
                    child: Text('${val.pin}-${val.name}'),
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
                      title: Text('${val.pin}-${val.alanname}'),
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
                      title: Text('PIN_ALANDET-${val.pin} / PINABITKI-${val.pinabitki}'),
                      subtitle: Text(val.epc),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Və ya etiket oxudun:', style: semibold16Style),
            const SizedBox(height: 10),
            TextField(
                controller: rfidTxt,
                enabled: false,
                decoration: const InputDecoration(hintText: constants.tRFID)),
            const SizedBox(height: 8),
            Expanded(
              child: Visibility(
                visible: _found,
                replacement: TextButton(
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
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const Spacer()
                    ],
                  ),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: kSmallPadding,
                    backgroundColor: kGreenColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(kDefaultRadius),
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TreeInfoScreen(
                        isRfid: rfidTxt.text.isNotEmpty,
                        rfid: rfidTxt.text,
                        pinAlanDet: _activeAlanDet?.pin,
                      ),
                    ),
                  ),
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
                            constants.tNext,
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
            ),
          ],
        ),
      ),
    );
  }
}
