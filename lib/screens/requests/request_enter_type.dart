import 'package:aqromis_application/models/request.dart';
import 'package:aqromis_application/screens/requests/select_garden.dart';
import 'package:aqromis_application/screens/requests/select_rfid.dart';
import 'package:aqromis_application/widgets/default_card.dart';
import 'package:flutter/material.dart';
import 'package:aqromis_application/text_constants.dart' as Constants;
import '../../constants.dart';

class RequestEnterTypeScreen extends StatefulWidget {
  final Request request;
  const RequestEnterTypeScreen(this.request);
  @override
  _RequestEnterTypeScreenState createState() => _RequestEnterTypeScreenState();
}

class _RequestEnterTypeScreenState extends State<RequestEnterTypeScreen> {
  final List<bool> _enterType = [
    false,
    false
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Constants.tSelectEnterType, style: semibold16Style),
      ),
      body: Padding(
        padding: kDefaultPadding,
        child: Column(
          children: <Widget>[
            Expanded(
              child: DefaultCard(
                color: kGreenColor,
                lightColor: kGreenOpacityColor,
                selected: _enterType[0],
                text: Constants.tSelectGarden,
                icon: Icons.grass_rounded,
                onPress: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SelectGardenScreen()));
                },
              ),
            ),
            const SizedBox(height: 24.0),
            Expanded(
              child: DefaultCard(
                color: kBlueColor,
                lightColor: kBlueOpacityColor,
                selected: _enterType[1],
                text: Constants.tSelectAutomatic,
                icon: Icons.speaker_phone_rounded,
                onPress: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SelectRFIDScreen(widget.request)));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
