import 'package:aqromis_application/data/operations/list_operations.dart';
import 'package:aqromis_application/data/shared_prefs.dart';
import 'package:aqromis_application/models/garden.dart';
import 'package:aqromis_application/screens/requests/select_tree.dart';
import 'package:aqromis_application/widgets/default_button.dart';
import 'package:aqromis_application/widgets/info_card.dart';
import 'package:aqromis_application/widgets/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:aqromis_application/text_constants.dart' as Constants;
import 'package:flutter/services.dart';

import '../../constants.dart';

class SelectGardenScreen extends StatefulWidget {
  @override
  _SelectGardenScreenState createState() => _SelectGardenScreenState();
}

class _SelectGardenScreenState extends State<SelectGardenScreen> {
  bool tips = false;
  bool loading = true;
  TextEditingController searchTxt = TextEditingController();
  List<Garden> gardens = [];
  final List<Garden> _searchResult = [];

  TextEditingController xsiraTxt = TextEditingController();
  TextEditingController ysiraTxt = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    getPrefs();
    getGardens();
    super.initState();
  }

  getGardens() async {
    await ListOperations.getGardenList()
        .then(
            (value) => value != false ? setState(() => gardens = value) : null)
        .then((value) => setState(() => loading = false));
  }

  getPrefs() async {
    await SharedData.getBool('tipsOpen')
        .then((value) => setState(() => tips = value ?? false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Constants.tSelectGarden, style: semibold16Style),
      ),
      body: Column(
        children: <Widget>[
          tips ? const InfoCard(text: Constants.tInfo3Text) : Container(),
          Padding(
            padding: kSmallPadding,
            child: Row(
              children: <Widget>[
                Container(
                  child: Expanded(
                    child: TextField(
                      controller: searchTxt,
                      onChanged: onSearchTextChanged,
                      decoration: const InputDecoration(
                          hintText: Constants.tGardenSearch,
                          prefixIcon:
                              Icon(Icons.search_rounded, color: kTextColor)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          loading
              ? CustomLoading()
              : Expanded(
                  child: _searchResult.isNotEmpty || searchTxt.text.isNotEmpty
                      ? ListView.builder(
                          itemCount: _searchResult.length,
                          itemBuilder: (context, i) {
                            return ListTile(
                              title: Text(_searchResult[i].name),
                              subtitle: Text(_searchResult[i].plantName),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SelectTreeScreen()));
                              },
                            );
                          },
                        )
                      : ListView.builder(
                          itemCount: gardens.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(gardens[index].name),
                              subtitle: Text(gardens[index].plantName),
                              onTap: () {
                                showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    barrierColor: Colors.black45,
                                    builder: (_) => SingleChildScrollView(
                                          child: AlertDialog(
                                            titlePadding:
                                                const EdgeInsets.all(0),
                                            elevation: 0,
                                            titleTextStyle: semibold14Style,
                                            contentTextStyle: semibold14Style,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  kDefaultRadius),
                                            ),
                                            title: Column(
                                              children: <Widget>[
                                                Padding(
                                                  padding: kDefaultPadding,
                                                  child: Form(
                                                    key: formKey,
                                                    child: Column(
                                                      children: <Widget>[
                                                        TextFormField(
                                                          autofocus: true,
                                                          controller: xsiraTxt,
                                                          //validator: (val) => TextValidator().validateTreeCount(val, widget.gardenResult.minTreeCount, widget.gardenResult.maxTreeCount),
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          inputFormatters: <
                                                              TextInputFormatter>[
                                                            FilteringTextInputFormatter
                                                                .digitsOnly
                                                          ],
                                                          decoration:
                                                              const InputDecoration(
                                                            labelText: Constants
                                                                .tSelectxNumber,
                                                            prefixIcon: Icon(Icons
                                                                .border_top_rounded),
                                                            enabledBorder: UnderlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        color:
                                                                            kInputTextColor,
                                                                        width:
                                                                            1.5)),
                                                            focusedBorder: UnderlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        color:
                                                                            kPrimaryColor,
                                                                        width:
                                                                            1.5)),
                                                            fillColor:
                                                                kWhiteColor,
                                                          ),
                                                        ),
                                                        TextFormField(
                                                          autofocus: true,
                                                          controller: ysiraTxt,
                                                          //validator: (val) => TextValidator().validateTreeCount(val, widget.gardenResult.minTreeCount, widget.gardenResult.maxTreeCount),
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          inputFormatters: <
                                                              TextInputFormatter>[
                                                            FilteringTextInputFormatter
                                                                .digitsOnly
                                                          ],
                                                          decoration:
                                                              const InputDecoration(
                                                            labelText: Constants
                                                                .tSelectyNumber,
                                                            prefixIcon: Icon(Icons
                                                                .border_left_rounded),
                                                            enabledBorder: UnderlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        color:
                                                                            kInputTextColor,
                                                                        width:
                                                                            1.5)),
                                                            focusedBorder: UnderlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        color:
                                                                            kPrimaryColor,
                                                                        width:
                                                                            1.5)),
                                                            fillColor:
                                                                kWhiteColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                DefaultButton(
                                                  backColor: kSecondaryColor,
                                                  textColor: kPrimaryColor,
                                                  text: Constants.tNext,
                                                  onPress: () {
                                                    if (ysiraTxt.text
                                                        .trim()
                                                        .isNotEmpty) {
                                                      if (formKey.currentState
                                                              ?.validate() ??
                                                          false) {
                                                        ysiraTxt.clear();
                                                      }
                                                    }
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ));
                              },
                            );
                          },
                        ),
                )
        ],
      ),
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      return;
    }

    for (var garden in gardens) {
      if (garden.name.contains(text.trim()) ||
          garden.name.contains(text.trim().toUpperCase()) ||
          garden.name.contains(text.trim().toLowerCase())) {
        setState(() => _searchResult.add(garden));
      }
    }
  }
}
