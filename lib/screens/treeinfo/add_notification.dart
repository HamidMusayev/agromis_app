import 'package:aqromis_application/data/operations/treeinfo.dart';
import 'package:aqromis_application/models/treeinfo/tree_notification.dart';
import 'package:aqromis_application/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:aqromis_application/text_constants.dart' as constants;

import '../../constants.dart';
import '../../data/shared_prefs.dart';
import '../../models/user.dart';
import '../../widgets/default_button.dart';

class AddNotification extends StatefulWidget {
  final int pinAlanDet;
  const AddNotification({Key? key, required this.pinAlanDet}) : super(key: key);

  @override
  State<AddNotification> createState() => _AddNotificationState();
}

class _AddNotificationState extends State<AddNotification> {
  TextEditingController titleTxt = TextEditingController();
  TextEditingController noteTxt = TextEditingController();
  bool loading = false;

  String? selectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Bildiriş və ya qeyd əlavə edin',
            style: semibold16Style),
      ),
      body: Padding(
        padding: kSmallPadding,
        child: buildEntry(),
      ),
    );
  }

  Future<bool> sendNotification() async {
    User user = User.fromJson(await SharedData.readJson('user'));
    TreeNotification notification = TreeNotification.tosend(
      createdUserCode: user.id.toString(),
      title: titleTxt.text,
      description: noteTxt.text,
      type: selectedType == 'Qeyd' ? 1 : 0,
      pinAlanDet: widget.pinAlanDet,
    );

    return await TreeInfoOperations.addNotification(notification);
  }

  buildEntry() {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: const BoxDecoration(
              color: kInputFillColor,
              borderRadius: BorderRadius.all(kDefaultRadius)),
          child: DropdownButton<String>(
            isExpanded: true,
            hint: const Text('Tip seçin...', style: semibold16Style),
            value: selectedType,
            icon: const Icon(Icons.arrow_drop_down_rounded),
            iconSize: kDefaultIconSize,
            elevation: 2,
            underline: const SizedBox(),
            onChanged: (String? newValue) =>
                setState(() => selectedType = newValue),
            items: [
              'Bildiriş',
              'Qeyd',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        const Divider(color: kWhiteColor),
        TextField(
            controller: titleTxt,
            maxLines: 1,
            decoration: const InputDecoration(hintText: constants.tAddTitle)),
        const Divider(color: kWhiteColor),
        TextField(
            controller: noteTxt,
            maxLines: 4,
            decoration: const InputDecoration(hintText: constants.tAddNote)),
        const Divider(
          color: kPrimaryColor,
          thickness: 2.0,
          indent: 40.0,
          endIndent: 40.0,
          height: 50.0,
        ),
        loading
            ? Center(
                child: Lottie.asset('assets/lottie/loading_small.json',
                    width: 150))
            : DefaultButton(
                text: constants.tCreate,
                textColor: kWhiteColor,
                backColor: kPrimaryColor,
                onPress: () {
                  if (selectedType == null) {
                    showAlert(constants.tTaskTypeError).timeout(
                        const Duration(seconds: 3),
                        onTimeout: () => Navigator.pop(context));
                  } else if (noteTxt.text.trim().isEmpty) {
                    showAlert(constants.tTaskNoteError).timeout(
                        const Duration(seconds: 3),
                        onTimeout: () => Navigator.pop(context));
                  } else {
                    setState(() => loading = true);
                    sendNotification().then((value) => value
                        ? Navigator.pop(context, const HomeScreen())
                        : showAlert('Əlavə olunarkən xəta baş verdi'));
                  }
                },
              )
      ],
    );
  }

  Future<void> showAlert(String text) {
    setState(() => loading = false);
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
}
