import 'package:aqromis_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UpdateAppPage extends StatelessWidget {
  final String link;

  const UpdateAppPage(this.link);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: const EdgeInsets.only(top: 180.0),
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              const Text('Yeniləmə mövcuddur. Sonuncu versiyanı quraşdırın.'),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.download_rounded,
                            color: kPrimaryColor),
                        onPressed: () async {
                          await canLaunchUrlString(link)
                              ? await launchUrlString(link)
                              : throw 'Link açılma xətası!';
                        },
                      ),
                      const Text('Yüklə', style: TextStyle(fontSize: 14))
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }
}
