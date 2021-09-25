import 'package:aqromis_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateAppPage extends StatelessWidget {
  final String link;

  UpdateAppPage(this.link);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(padding: EdgeInsets.only(top: 180.0), alignment: Alignment.center, child: Column(
        children: <Widget>[
          Text("Yeniləmə mövcuddur. Sonuncu versiyanı quraşdırın."),
          Container(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child:Center(
              child: Column(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.download_rounded, color: kPrimaryColor),
                    onPressed: () async {
                      await canLaunch(link)
                          ? await launch(link)
                          : throw 'Link açılma xətası!';
                    },
                  ),
                  Text("Yüklə", style: TextStyle(fontSize: 14))
                ],
              ),
            ),
          )
        ],
      )),
    );
  }
}
