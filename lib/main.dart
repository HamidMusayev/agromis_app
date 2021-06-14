import 'package:aqromis_application/data/shared_prefs.dart';
import 'package:aqromis_application/screens/home.dart';
import 'package:aqromis_application/screens/sign_in.dart';
import 'package:aqromis_application/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,//navigation bar color
    statusBarColor: Colors.transparent,// status bar color
    statusBarBrightness: Brightness.dark,//status bar brightness
    statusBarIconBrightness:Brightness.dark,//status barIcon Brightness
    systemNavigationBarDividerColor: Colors.black,//Navigation bar divider color
    systemNavigationBarIconBrightness: Brightness.dark,//navigation bar icon
  ));

  runApp(MainScreen());
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isSave = false;
  @override
  void initState() {
    getPrefs();
    super.initState();
  }

  getPrefs() async{
    await SharedData.getBool("isLoginSave").then((value) => setState(() => isSave = value != null ? value : false));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AGROMIS',
      theme: theme(),
      debugShowCheckedModeBanner: false,
      home: isSave ? HomeScreen() : SignInScreen(),
    );
  }
}

