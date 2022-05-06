import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:aqromis_application/data/operations/request.dart';
import 'package:aqromis_application/data/shared_prefs.dart';
import 'package:aqromis_application/models/picture.dart';
import 'package:aqromis_application/models/request.dart';
import 'package:aqromis_application/models/user.dart';
import 'package:aqromis_application/widgets/default_button.dart';
import 'package:aqromis_application/widgets/picture_holder.dart';
import 'package:aqromis_application/widgets/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:aqromis_application/text_constants.dart' as constants;
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants.dart';

class SelectPictureScreen extends StatefulWidget {
  final Request request;
  const SelectPictureScreen({required this.request});
  @override
  _SelectPictureScreenState createState() => _SelectPictureScreenState(request);
}

class _SelectPictureScreenState extends State<SelectPictureScreen> {
  late Request request;
  _SelectPictureScreenState(this.request);
  int count = 0;
  String? photoBase64;
  List<Picture> pictures = [];

  final ImagePicker _picker = ImagePicker();
  TextEditingController titleTxt = TextEditingController();
  TextEditingController noteTxt = TextEditingController();

  void _onImageButtonPressed(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
          source:
              source); // maxWidth: maxWidth,// maxHeight: maxHeight,// imageQuality: quality,

      File imageResized = await FlutterNativeImage.compressImage(
          pickedFile!.path,
          quality: 60); //targetWidth: 1000, targetHeight: 1000
      List<int> imageBytes = imageResized.readAsBytesSync();
      photoBase64 = base64Encode(imageBytes);

      Picture picture = Picture(path: '', base64: '');
      picture.path = pickedFile.path;
      picture.base64 = photoBase64!;

      setState(() => pictures.add(picture));
    } catch (e) {}
  }

  Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(constants.tSelectPhotos, style: semibold16Style)),
      body: SingleChildScrollView(
        child: Padding(
          padding: kSmallPadding,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      child: pictures.length < 5
                          ? TextButton(
                              style: TextButton.styleFrom(
                                padding: kDefaultPadding,
                                backgroundColor: kBlueOpacityColor,
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(kDefaultRadius),
                                ),
                              ),
                              child: const Icon(Icons.add_a_photo_rounded,
                                  color: kBlueColor, size: 50),
                              onPressed: () =>
                                  _onImageButtonPressed(ImageSource.camera),
                            )
                          : TextButton(
                              style: TextButton.styleFrom(
                                padding: kDefaultPadding,
                                backgroundColor: kInputFillColor,
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(kDefaultRadius),
                                ),
                              ),
                              child: const Icon(Icons.add_a_photo_rounded,
                                  color: kInputTextColor, size: 52),
                              onPressed: () {},
                            )),
                  const SizedBox(width: 12),
                  Expanded(
                      child: pictures.length < 5
                          ? TextButton(
                              style: TextButton.styleFrom(
                                padding: kDefaultPadding,
                                backgroundColor: kPrimaryOpacityColor,
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(kDefaultRadius),
                                ),
                              ),
                              child: const Icon(
                                  Icons.add_photo_alternate_rounded,
                                  color: kPrimaryColor,
                                  size: 50),
                              onPressed: () {
                                _onImageButtonPressed(ImageSource.gallery);
                              },
                            )
                          : TextButton(
                              style: TextButton.styleFrom(
                                padding: kDefaultPadding,
                                backgroundColor: kInputFillColor,
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(kDefaultRadius),
                                ),
                              ),
                              child: const Icon(
                                  Icons.add_photo_alternate_rounded,
                                  color: kInputTextColor,
                                  size: 50),
                              onPressed: () {},
                            )),
                ],
              ),
              Padding(
                  padding: kSmallPadding,
                  child: GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      shrinkWrap: true,
                      children: <Widget>[
                        ...pictures.map(
                            (Picture holder) => PictureHolder(holder.path, () {
                                  setState(() => pictures.remove(holder));
                                }))
                      ])),
              const SizedBox(height: 100),
              TextField(
                  controller: titleTxt,
                  decoration:
                      const InputDecoration(hintText: constants.tAddTitle)),
              const SizedBox(height: 12),
              TextField(
                  controller: noteTxt,
                  maxLines: 4,
                  decoration:
                      const InputDecoration(hintText: constants.tAddNote)),
              const SizedBox(height: 30),
              DefaultButton(
                text: constants.tSend,
                textColor: kWhiteColor,
                backColor: kPrimaryColor,
                onPress: () {
                  if (pictures.isEmpty) {
                    showAlert(constants.tPhotosError).timeout(
                        const Duration(seconds: 3),
                        onTimeout: () => Navigator.pop(context));
                  } else if (titleTxt.text.trim().isEmpty) {
                    showAlert(constants.tTtileError).timeout(
                        const Duration(seconds: 3),
                        onTimeout: () => Navigator.pop(context));
                  } else {
                    uploadData();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> buildSendDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black45,
      builder: (_) => AlertDialog(
        elevation: 0,
        titleTextStyle: semibold14Style,
        contentTextStyle: semibold14Style,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(kDefaultRadius)),
        title: StatefulBuilder(
          builder: (BuildContext context, StateSetter setSt) {
            return Column(
              children: <Widget>[
                const Icon(Icons.cloud_upload_rounded,
                    color: kPrimaryColor, size: 50.0),
                const SizedBox(height: 10.0),
                const Text(constants.tUploading),
                const SizedBox(height: 16.0),
                CustomLoading()
              ],
            );
          },
        ),
      ),
    );
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

  uploadData() async {
    buildSendDialog();
    User user = User.fromJson(await SharedData.readJson('user'));

    List<String> picsbase64 = [];
    for (var pic in pictures) {
      picsbase64.add(pic.base64);
    }
    while (picsbase64.length < 5) {
      picsbase64.add('empty');
    }

    request.pictures = picsbase64;
    request.title = titleTxt.text.trim();
    request.description = noteTxt.text.trim();
    request.createusercode = user.id!;

    await RequestOperations.sendRequest(request).then((value) {
      if (value) {
        goToMain();
      }
    });
  }

  goToMain() {
    return Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
