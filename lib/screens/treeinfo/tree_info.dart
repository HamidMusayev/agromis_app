import 'package:aqromis_application/constants.dart';
import 'package:aqromis_application/data/operations/treeinfo.dart';
import 'package:aqromis_application/models/treeinfo/tree_detail.dart';
import 'package:flutter/material.dart';
import 'package:aqromis_application/text_constants.dart' as constants;

import '../../data/operations/list.dart';
import '../../models/treeinfo/tree_notification.dart';

class TreeInfoScreen extends StatefulWidget {
  final bool isRfid;
  final String? pinAlanDet;
  final String rfid;
  const TreeInfoScreen(
      {Key? key, required this.isRfid, this.pinAlanDet, required this.rfid})
      : super(key: key);

  @override
  State<TreeInfoScreen> createState() => _TreeInfoScreenState();
}

class _TreeInfoScreenState extends State<TreeInfoScreen>
    with TickerProviderStateMixin {
  late TabController tabController;
  bool isLoading = true;

  TreeDetail _treeDetail = TreeDetail(
      pinAlanDet: 0,
      bitkiCesit: '',
      bitkiTur: '',
      lastVisitDate: '',
      lastVisitType: '',
      lastVisitedUser: '');

  List<TreeNotification> _all = [];
  List<TreeNotification> _notes = [];
  List<TreeNotification> _alarms = [];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    getTreeDetail();
    getNotifications();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<void> getNotifications() async {
    setState(() => isLoading = true);

    await ListOperations.getNotificationList(
            widget.rfid, widget.pinAlanDet ?? '', widget.isRfid)
        .then((value) {
      if (value != false) {
        _all = value;
        _notes = _all.where((element) => element.type == 1).toList();
        _alarms = _all.where((element) => element.type == 0).toList();

        setState(() => isLoading = false);
      } else {
        showAlert(constants.tCantFindRFIDNetworkError);
      }
    });
  }

  Future<void> getTreeDetail() async {
    setState(() => isLoading = true);

    await TreeInfoOperations.getTreeDetail(
            widget.rfid, widget.pinAlanDet ?? '', widget.isRfid)
        .then((value) {
      if (value != false) {
        _treeDetail = value;
        setState(() => isLoading = false);
      } else {
        showAlert(constants.tCantFindRFIDNetworkError);
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Ağac məlumatları',
            style: TextStyle(color: Colors.black, fontSize: 17)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Visibility(
        visible: isLoading,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
        replacement: NestedScrollView(
          headerSliverBuilder: (context, value) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: kSmallPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 180,
                      padding: kSmallPadding,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: const BorderRadius.all(kDefaultRadius),
                      ),
                      child: GridView.count(
                        childAspectRatio: 6,
                        crossAxisCount: 2,
                        children: [
                          const Text('PIN_ALANDET:'),
                          Text(_treeDetail.pinAlanDet.toString()),
                          const Text('Bitki növü:'),
                          Text(_treeDetail.bitkiTur),
                          const Text('Bitki çeşidi:'),
                          Text(_treeDetail.bitkiCesit),
                          const Text('Son iş görülmə tarixi:'),
                          Text(_treeDetail.lastVisitDate),
                          const Text('Son iş növü:'),
                          Text(_treeDetail.lastVisitType),
                          const Text('Son işi edən bağban:'),
                          Text(_treeDetail.lastVisitedUser),
                        ],
                      ),
                    ),
                    TabBar(
                      controller: tabController,
                      isScrollable: true,
                      tabs: const [
                        Tab(child: Text('Qeydlər')),
                        Tab(child: Text('Bildirişlər')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: tabController,
            children: [
              ListView.builder(
                itemCount: _notes.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) => ExpansionTile(
                  childrenPadding: kSmallPadding,
                  expandedAlignment: Alignment.centerLeft,
                  title: Text(_notes[index].title),
                  subtitle: Text(
                      '${_notes[index].createdDate} - ${_notes[index].createdUser}'),
                  children: [Text(_notes[index].description)],
                ),
              ),
              ListView.builder(
                itemCount: _alarms.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) => ExpansionTile(
                  childrenPadding: kSmallPadding,
                  expandedAlignment: Alignment.centerLeft,
                  title: Text(_alarms[index].title),
                  subtitle: Text(
                      '${_alarms[index].createdDate} - ${_alarms[index].createdUser}'),
                  children: [Text(_alarms[index].description)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
