import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:aqromis_application/data/operations/request_operations.dart';
import 'package:aqromis_application/data/shared_prefs.dart';
import 'package:aqromis_application/models/picture.dart';
import 'package:aqromis_application/models/request.dart';
import 'package:aqromis_application/models/user.dart';
import 'package:aqromis_application/size_config.dart';
import 'package:aqromis_application/widgets/default_button.dart';
import 'package:aqromis_application/widgets/picture_holder.dart';
import 'package:aqromis_application/widgets/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:aqromis_application/text_constants.dart' as Constants;
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants.dart';

class SelectPictureScreen extends StatefulWidget {
  final Request request;
  SelectPictureScreen({this.request});
  @override
  _SelectPictureScreenState createState() => _SelectPictureScreenState(request);
}

class _SelectPictureScreenState extends State<SelectPictureScreen> {
  Request request;
  _SelectPictureScreenState(this.request);
  int count = 0;
  String photoBase64;
  List<Picture> pictures = [];

  final ImagePicker _picker = ImagePicker();
  TextEditingController titleTxt = TextEditingController();
  TextEditingController noteTxt = TextEditingController();

  void _onImageButtonPressed(ImageSource source) async {
    try {
      final pickedFile = await _picker.getImage(source: source);// maxWidth: maxWidth,// maxHeight: maxHeight,// imageQuality: quality,

      File imageResized = await FlutterNativeImage.compressImage(
          pickedFile.path,
          quality: 60);//targetWidth: 1000, targetHeight: 1000
      List<int> imageBytes = imageResized.readAsBytesSync();
      photoBase64 = base64Encode(imageBytes);

      Picture picture = Picture();
      picture.path = pickedFile.path;
      picture.base64 = photoBase64;

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
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(Constants.tSelectPhotos, style: semibold16Style)),
      body: SingleChildScrollView(
        child: Padding(
          padding: kSmallPadding,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      child: pictures.length < 5
                          ? FlatButton(
                              padding: kDefaultPadding,
                              color: kBlueOpacityColor,
                              splashColor: kWhiteColor,
                              highlightColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(kDefaultRadius)),
                              child: Icon(Icons.add_a_photo_rounded, color: kBlueColor, size: getProportionateScreenHeight(50.0)),
                              onPressed: () => _onImageButtonPressed(ImageSource.camera),
                            )
                          : FlatButton(
                              padding: kDefaultPadding,
                              color: kInputFillColor,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(kDefaultRadius)),
                              child: Icon(Icons.add_a_photo_rounded,
                                  color: kInputTextColor,
                                  size: getProportionateScreenHeight(50.0)),
                              onPressed: () {},
                            )),
                  SizedBox(width: getProportionateScreenHeight(10.0)),
                  Expanded(
                      child: pictures.length < 5
                          ? FlatButton(
                              padding: kDefaultPadding,
                              color: kPrimaryOpacityColor,
                              splashColor: kWhiteColor,
                              highlightColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(kDefaultRadius)),
                              child: Icon(Icons.add_photo_alternate_rounded,
                                  color: kPrimaryColor,
                                  size: getProportionateScreenHeight(50.0)),
                              onPressed: () {
                                _onImageButtonPressed(ImageSource.gallery);
                              },
                            )
                          : FlatButton(
                              padding: kDefaultPadding,
                              color: kInputFillColor,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(kDefaultRadius)),
                              child: Icon(Icons.add_photo_alternate_rounded,
                                  color: kInputTextColor,
                                  size: getProportionateScreenHeight(50.0)),
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
              SizedBox(height: getProportionateScreenHeight(100.0)),
              TextField(
                  controller: titleTxt,
                  decoration: InputDecoration(hintText: Constants.tAddTitle)),
              SizedBox(height: getProportionateScreenHeight(10.0)),
              TextField(
                  controller: noteTxt,
                  maxLines: 4,
                  decoration: InputDecoration(hintText: Constants.tAddNote)),
              SizedBox(height: getProportionateScreenHeight(30.0)),
              DefaultButton(
                text: Constants.tSend,
                textColor: kWhiteColor,
                backColor: kPrimaryColor,
                onPress: () {
                  if (pictures.length == 0) {
                    showAlert(Constants.tPhotosError).timeout(Duration(seconds: 3), onTimeout: () => Navigator.pop(context));
                  } else if (titleTxt == null || titleTxt.text.trim().isEmpty) {
                    showAlert(Constants.tTtileError).timeout(Duration(seconds: 3), onTimeout: () => Navigator.pop(context));
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(kDefaultRadius)),
        title: StatefulBuilder(
          builder: (BuildContext context, StateSetter setSt) {
            return Column(
              children: <Widget>[
                Icon(Icons.cloud_upload_rounded,
                    color: kPrimaryColor, size: 50.0),
                SizedBox(height: 10.0),
                Text(Constants.tUploading),
                SizedBox(height: 16.0),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(kDefaultRadius)),
        title: Column(
          children: <Widget>[
            Icon(Icons.info, color: kBlueColor, size: 50.0),
            SizedBox(height: 12.0),
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  uploadData() async {
    buildSendDialog();
    User user = User.fromJson(await SharedData.readJson("user"));

    List<String> picsbase64 = [];
    pictures.forEach((pic) => picsbase64.add(pic.base64));
    while(picsbase64.length < 5){
      picsbase64.add("empty");
    }

    request.pictures = picsbase64;
    request.title = titleTxt.text.trim();
    request.description = noteTxt.text.trim();
    request.createusercode = user.id;

    await RequestOperations.sendRequest(request).then((value) {
      if(value){
        goToMain();
      }
    });
  }

  goToMain(){
    return Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
