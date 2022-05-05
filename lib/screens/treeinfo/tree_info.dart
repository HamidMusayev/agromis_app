import 'package:aqromis_application/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:aqromis_application/text_constants.dart' as constants;

import '../../data/operations/list_operations.dart';
import '../../models/tree_notification.dart';

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

  List<TreeNotification> _all = [];
  List<TreeNotification> _notes = [];
  List<TreeNotification> _alarms = [];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
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
        debugPrintThrottled(
            '_notes: ${_notes.length}, _alarms: ${_alarms.length}');

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
                      height: 160,
                      padding: kSmallPadding,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: const BorderRadius.all(kDefaultRadius),
                      ),
                      child: GridView.count(
                        childAspectRatio: 6,
                        crossAxisCount: 2,
                        children: const [
                          Text('PIN_ALANDET:'),
                          Text('12'),
                          Text('Bitki növü:'),
                          Text('chiels'),
                          Text('Son işlənmə tarixi:'),
                          Text('12-02-2022'),
                          Text('Son iş növü:'),
                          Text('BUDAMA'),
                          Text('Son işi edən bağban:'),
                          Text('cvg'),
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
