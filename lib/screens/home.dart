import 'dart:io';
import 'package:aqromis_application/constants.dart';
import 'package:aqromis_application/data/shared_prefs.dart';
import 'package:aqromis_application/models/app_info.dart';
import 'package:aqromis_application/models/user.dart';
import 'package:aqromis_application/screens/drawer/settings.dart';
import 'package:aqromis_application/screens/requests/request_type.dart';
import 'package:aqromis_application/screens/sign_in.dart';
import 'package:aqromis_application/screens/tasks/tasks.dart';
import 'package:aqromis_application/screens/treeinfo/pick_tree.dart';
import 'package:aqromis_application/screens/update_app.dart';
import 'package:aqromis_application/utils/date_time.dart';
import 'package:aqromis_application/widgets/error_card.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:aqromis_application/text_constants.dart' as constants;
import 'package:uhf_c72_plugin/uhf_c72_plugin.dart';
import 'package:xml/xml.dart' as xml;
import '../data/local_send_db.dart';
import '../data/operations/app.dart';
import '../data/web_service.dart';
import '../models/send_data_db.dart';
import 'set_tree.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CustomDate date = CustomDate('', '', '');
  User _user = User.withid(0, '', '', '', '');
  AppInfo _info = AppInfo(
      name: 'AGROMIS',
      userTaskCount: 0,
      version: 2,
      updatedDate: ' ',
      downloadLink: ' ',
      developerEmail: ' ',
      developerName: ' ',
      developerPhone: ' ',
      developerSite: ' ');
  int _cnnStatus = 0;
  int _locStatus = 0;

  Location location = Location();

  List<SendDataDB> _mustSendTasks = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
    getPrefsAndDB();
    date = CustomDate.getCurDate();

    checkConnectionStream().listen((event) {
      setState(() => _cnnStatus = event);
      if (_cnnStatus == 1) _offlineOperations();
    });

    checkLocationStream().listen((event) {
      setState(() => _locStatus = event);
    });
  }

  Stream<int> checkConnectionStream() async* {
    yield* Stream.periodic(const Duration(seconds: 2), (_) async {
      return await _checkConnection();
    }).asyncMap((event) async => await event);
  }

  Stream<int> checkLocationStream() async* {
    yield* Stream.periodic(const Duration(seconds: 2), (_) async {
      return await _checkLocation();
    }).asyncMap((event) async => await event);
  }

  Future<int> _checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return 1;
      } else {
        return 0;
      }
    } on SocketException catch (_) {
      return 0;
    }
  }

  Future<int> _checkLocation() async {
    final bool loc = await location.serviceEnabled();
    if (loc == false) {
      _requestService();
    }
    return loc ? 1 : 0;
  }

  Future<void> _offlineOperations() async {
    for (var element in _mustSendTasks) {
      await WebService.sendRequest(element.methodName, element.sendDataXml)
          .then((value) async {
        if (value.result.single.findElements('IsSuccessful').single.innerText ==
            'true') {
          await LocalSendDB().delete(element.pinData);
          setState(() => _mustSendTasks.remove(element));
        }
      });
    }
  }

  Future<void> initPlatformState() async {
    String range = '6';
    await SharedData.getInt('range').then(
        (value) => value != null ? range = value.toString() : range = '6');

    UhfC72Plugin.connectedStatusStream.receiveBroadcastStream();
    //UhfC72Plugin.tagsStatusStream.receiveBroadcastStream().listen(updateTags);
    await UhfC72Plugin.connect;
    await UhfC72Plugin.setWorkArea('2');
    await UhfC72Plugin.setPowerLevel(range);
    if (!mounted) return;
  }

  FutureOr onGoBack(dynamic value) {
    stopConnection();
  }

  stopConnection() async {
    String range = '6';
    await SharedData.getInt('range').then((value) {
      if (value != null) range = value.toString();
    });
    await UhfC72Plugin.setPowerLevel(range);
  }

  getPrefsAndDB() async {
    User user = User.fromJson(await SharedData.readJson('user'));
    setState(() => _user = user);
    await SharedData.getBool('tipsOpen').then(
        (value) => value == null ? SharedData.setBool('tipsOpen', true) : true);
    await AppOperations.getAppInfo(_user.id!)
        .then((value) => value != false ? setState(() => _info = value) : null);
    await LocalSendDB().getDataList().then((value) => _mustSendTasks = value);
  }

  Future<void> _requestService() async {
    final bool serviceRequestedResult = await location.requestService();
    setState(() => _locStatus = serviceRequestedResult ? 1 : 0);
    if (!serviceRequestedResult) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _info.version == 4
        ? Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(date.curDate, style: semibold16Style),
                  Text(_user.name, style: light14Style),
                ],
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _locStatus == 1
                      ? const Icon(Icons.location_on_rounded,
                          color: kGreenColor, size: kDefaultIconSize)
                      : const Icon(Icons.location_off_rounded,
                          color: kRedColor, size: kDefaultIconSize),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: _cnnStatus == 1
                      ? const Icon(Icons.wifi_rounded,
                          color: kGreenColor, size: kDefaultIconSize)
                      : const Icon(Icons.wifi_off_rounded,
                          color: kRedColor, size: kDefaultIconSize),
                ),
              ],
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Spacer(),
                        Text(_user.name),
                        const Text(constants.tMainMenu, style: light14Style),
                      ],
                    ),
                    decoration: const BoxDecoration(color: kWhiteColor),
                  ),
                  ListTile(
                    title: const Text(constants.tAppDetail),
                    leading: const Icon(Icons.info_rounded),
                    onTap: () => showAbout(_info),
                  ),
                  ListTile(
                    title: const Text(constants.tSettings),
                    leading: const Icon(Icons.settings_rounded),
                    onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SettingsScreen()))
                        .then(onGoBack),
                  ),
                  ListTile(
                    title: const Text(constants.tLogOut),
                    leading: const Icon(Icons.logout, color: kRedColor),
                    onTap: () => buildLogOutDialog(),
                  ),
                ],
              ),
            ),
            body: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 1000),
                  crossFadeState: _mustSendTasks.isEmpty
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Container(),
                  secondChild: Padding(
                    padding: kSmallPadding,
                    child: ErrorCard(
                      title: _mustSendTasks.length.toString() +
                          constants.tHaveSendableActionsTitle,
                      text: constants.tHaveSendableActionsText,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: GridView.count(
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    padding: kSmallPadding,
                    physics: const BouncingScrollPhysics(),
                    crossAxisCount: 2,
                    children: <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: kDefaultPadding,
                          backgroundColor: kPrimaryColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(kDefaultRadius),
                          ),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TasksScreen()),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              _info.userTaskCount.toString(),
                              style: const TextStyle(
                                color: kWhiteColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 60,
                              ),
                            ),
                            Text(constants.tTasksTitle.toString(),
                                style: semibold16WhiteStyle)
                          ],
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: kGreenColor,
                          padding: kDefaultPadding,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(kDefaultRadius),
                          ),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RequestTypeScreen()),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Icon(
                              Icons.forward_to_inbox_rounded,
                              color: Colors.white,
                              size: 80,
                            ),
                            Text(constants.tRequestsTitle,
                                style: semibold16WhiteStyle)
                          ],
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: kDefaultPadding,
                          backgroundColor: kYellowColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(kDefaultRadius),
                          ),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SetTreeScreen()),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Icon(
                              Icons.park_rounded,
                              color: Colors.white,
                              size: 80,
                            ),
                            Text(constants.tTreeTitle.toString(),
                                style: semibold16WhiteStyle)
                          ],
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: kDefaultPadding,
                          backgroundColor: kRedColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(kDefaultRadius),
                          ),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PickTreeScreen()),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Icon(
                              Icons.info_rounded,
                              color: Colors.white,
                              size: 80,
                            ),
                            Text(constants.tTreeInfoTitle.toString(),
                                style: semibold16WhiteStyle)
                          ],
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: kDefaultPadding,
                          backgroundColor: kLavendeColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(kDefaultRadius),
                          ),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SetTreeScreen()),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Icon(
                              Icons.notifications_on_rounded,
                              color: Colors.white,
                              size: 80,
                            ),
                            Text(
                              constants.tTreeNotificationsTitle.toString(),
                              style: semibold16WhiteStyle,
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        : UpdateAppPage(_info.downloadLink);
  }

  showAbout(AppInfo info) {
    return showAboutDialog(
      context: context,
      applicationIcon: Image.asset(
        'assets/images/ic_launcher.png',
        width: 60,
      ),
      applicationName: info.name,
      applicationVersion: 'v' + info.version.toString(),
      children: <Widget>[
        Text('Tərtibatçı: ' + info.developerName),
        Text('E-mail: ' + info.developerEmail),
        Text('Keçid linki: ' + info.developerSite),
        Text('Telefon: ' + info.developerPhone),
      ],
    );
  }

  Future<dynamic> buildLogOutDialog() {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black45,
      builder: (_) => AlertDialog(
        elevation: 0,
        contentPadding: kDefaultPadding,
        titleTextStyle: semibold14Style,
        contentTextStyle: semibold14Style,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(kDefaultRadius)),
        title: Column(
          children: const <Widget>[
            Icon(Icons.logout, color: kRedColor, size: 50.0),
            SizedBox(height: 12.0),
            Text(constants.tLogOutQuestion, textAlign: TextAlign.center),
          ],
        ),
        actions: <Widget>[
          TextButton(
              onPressed: () => logOut(),
              child: const Text(
                constants.tYes,
                style: TextStyle(color: kTextColor),
              )),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(constants.tNo,
                  style: TextStyle(color: kTextColor)))
        ],
      ),
    );
  }

  logOut() {
    SharedData.removeJson('user');
    SharedData.setBool('isLoginSave', false);
    Navigator.pushAndRemoveUntil<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => const SignInScreen()),
        (route) => false);
  }
}
