import 'dart:io';
import 'package:aqromis_application/constants.dart';
import 'package:aqromis_application/data/operations/app_operations.dart';
import 'package:aqromis_application/data/shared_prefs.dart';
import 'package:aqromis_application/models/app_info.dart';
import 'package:aqromis_application/models/user.dart';
import 'package:aqromis_application/screens/drawer/settings.dart';
import 'package:aqromis_application/screens/requests/request_type.dart';
import 'package:aqromis_application/screens/sign_in.dart';
import 'package:aqromis_application/screens/tasks/tasks.dart';
import 'package:aqromis_application/screens/update_app.dart';
import 'package:aqromis_application/utils/date_time.dart';
import 'package:aqromis_application/widgets/error_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:aqromis_application/text_constants.dart' as Constants;
import 'package:uhf_c72_plugin/uhf_c72_plugin.dart';
import 'package:xml/xml.dart' as xml;
import '../data/local_send_db.dart';
import '../data/web_service.dart';
import '../models/send_data_db.dart';
import '../size_config.dart';
import 'drawer/set_tree.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CustomDate date = CustomDate("", "", "");
  User _user = User.withid(0, "", "", "", "");
  AppInfo _info = AppInfo(
      name: "AGROMIS",
      userTaskCount: 0,
      version: 2,
      updatedDate: " ",
      downloadLink: " ",
      developerEmail: " ",
      developerName: " ",
      developerPhone: " ",
      developerSite: " ");
  int _cnnStatus = 0;
  int _locStatus = 0;

  Location location = new Location();

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
    _mustSendTasks.forEach((element) async {
      await WebService.sendRequest(element.methodName, element.sendDataXml)
          .then((value) async {
        if (value.result.single.findElements("IsSuccessful").single.innerText ==
            "true") {
          await LocalSendDB().delete(element.pinData);
          setState(() => _mustSendTasks.remove(element));
        }
      });
    });
  }

  Future<void> initPlatformState() async {
    String range = "6";
    await SharedData.getInt("range").then(
        (value) => value != null ? range = value.toString() : range = "6");

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
    String range;
    await SharedData.getInt("range").then(
        (value) => value != null ? range = value.toString() : range = "6");
    await UhfC72Plugin.setPowerLevel(range);
  }

  getPrefsAndDB() async {
    User user = User.fromJson(await SharedData.readJson("user"));
    setState(() => _user = user);
    await SharedData.getBool("tipsOpen").then(
        (value) => value == null ? SharedData.setBool("tipsOpen", true) : true);
    await AppOperations.getAppInfo(_user.id)
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
    return _info.version == 4 ? Scaffold(
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
                ? Icon(Icons.location_on_rounded,
                    color: kGreenColor, size: kDefaultIconSize)
                : Icon(Icons.location_off_rounded,
                    color: kRedColor, size: kDefaultIconSize),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: _cnnStatus == 1
                ? Icon(Icons.wifi_rounded,
                    color: kGreenColor, size: kDefaultIconSize)
                : Icon(Icons.wifi_off_rounded,
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
                  Spacer(),
                  Text(_user.name),
                  Text(Constants.tMainMenu, style: light14Style),
                ],
              ),
              decoration: BoxDecoration(color: kWhiteColor),
            ),
            ListTile(
              title: Text(Constants.tSetTree),
              leading: Icon(Icons.park),
              onTap: () =>  Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SetTreeScreen())),
            ),
            ListTile(
              title: Text(Constants.tAppDetail),
              leading: Icon(Icons.info_rounded),
              onTap: () => showAbout(_info),
            ),
            ListTile(
              title: Text(Constants.tSettings),
              leading: Icon(Icons.settings_rounded),
              onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()))
                  .then(onGoBack),
            ),
            ListTile(
              title: Text(Constants.tLogOut),
              leading: Icon(Icons.logout, color: kRedColor),
              onTap: () => buildLogOutDialog(),
            ),
          ],
        ),
      ),
      body: Container(
        padding: kSmallPadding,
        child: Column(
          children: <Widget>[
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 1000),
              crossFadeState: _mustSendTasks.length == 0
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Container(),
              secondChild: ErrorCard(
                title: _mustSendTasks.length.toString() +
                    Constants.tHaveSendableActionsTitle,
                text: Constants.tHaveSendableActionsText,
              ),
            ),
            SizedBox(height: 8.0),
            SizedBox(
              height: 160.0,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      splashColor: kInputFillColor,
                      padding: kDefaultPadding,
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) => TasksScreen())),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(kDefaultRadius)),
                      color: kPrimaryColor,
                      height: getProportionateScreenHeight(70.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(_info.userTaskCount.toString(),
                              style: TextStyle(
                                  color: kWhiteColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize:
                                      getProportionateScreenHeight(60.0))),
                          Text(Constants.tTasksTitle.toString(),
                              style: semibold16WhiteStyle)
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: FlatButton(
                      splashColor: kInputFillColor,
                      padding: kDefaultPadding,
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RequestTypeScreen())),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(kDefaultRadius)),
                      color: kGreenColor,
                      height: getProportionateScreenHeight(70.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.forward_to_inbox_rounded,
                              color: Colors.white,
                              size: getProportionateScreenHeight(90.0)),
                          Text(Constants.tRequestsTitle,
                              style: semibold16WhiteStyle)
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ) : UpdateAppPage(_info.downloadLink);
  }

  showAbout(AppInfo info) {
    return showAboutDialog(
      context: context,
      applicationIcon: Image.asset(
        "assets/images/ic_launcher.png",
        width: 60,
      ),
      applicationName: info.name,
      applicationVersion: "v" + info.version.toString(),
      children: <Widget>[
        Text("Tərtibatçı: " + info.developerName),
        Text("E-mail: " + info.developerEmail),
        Text("Keçid linki: " + info.developerSite),
        Text("Telefon: " + info.developerPhone),
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(kDefaultRadius)),
        title: Column(
          children: <Widget>[
            Icon(Icons.logout, color: kRedColor, size: 50.0),
            SizedBox(height: 12.0),
            Text(Constants.tLogOutQuestion, textAlign: TextAlign.center),
          ],
        ),
        actions: <Widget>[
          FlatButton(
              onPressed: () => logOut(),
              child: Text(
                Constants.tYes,
                style: TextStyle(color: kTextColor),
              )),
          FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text(Constants.tNo, style: TextStyle(color: kTextColor)))
        ],
      ),
    );
  }

  logOut() {
    SharedData.removeJson("user");
    SharedData.setBool("isLoginSave", false);
    Navigator.pushAndRemoveUntil<dynamic>(context, MaterialPageRoute<dynamic>(builder: (BuildContext context) => SignInScreen()), (route) => false);
  }
}
