import 'package:aqromis_application/models/response.dart';
import 'package:aqromis_application/models/treeinfo/tree_detail.dart';
import 'package:aqromis_application/models/treeinfo/tree_notification.dart';

import '../web_service.dart';
import 'package:xml/xml.dart' as xml;

class TreeInfoOperations {
  static Future<dynamic> getTreeDetail(
      String rfid, String pinAlanDet, bool isRfid) async {
    String dataXML = '<rfid>$rfid</rfid>'
        '<pinAlanDet>$pinAlanDet</pinAlanDet>'
        '<isRfid>$isRfid</isRfid>'
        '<isAlan>false</isAlan>'
        '<pinAlan>sss</pinAlan>';

    final Response response =
        await WebService.sendRequest('GetTreeDetail', dataXML);

    if (response.isConnected) {
      if (response.result.single
              .findElements('OperationState')
              .single
              .findElements('IsSuccessful')
              .single
              .innerText ==
          'true') {
        final treedetail =
            response.result.single.findElements('TreeDetail').single;
        return TreeDetail(
          pinAlanDet:
              int.parse(treedetail.findElements('PinAlanDet').single.innerText),
          bitkiCesit: treedetail.findElements('BitkiCesit').single.innerText,
          bitkiTur: treedetail.findElements('BitkiTur').single.innerText,
          lastVisitDate:
              treedetail.findElements('LastVisitDate').single.innerText,
          lastVisitType:
              treedetail.findElements('LastVisitType').single.innerText,
          lastVisitedUser:
              treedetail.findElements('LastVisitedUser').single.innerText,
        );
      }
    } else {
      return false;
    }
  }

  static Future<bool> addNotification(TreeNotification notification) async {
    final String dataXML = '<notification>'
        '<PinNotification>${notification.pinNotification}</PinNotification>'
        '<Title>${notification.title}</Title>'
        '<Description>${notification.description}</Description>'
        '<CreatedUserCode>${notification.createdUserCode}</CreatedUserCode>'
        '<CreatedUser>${notification.createdUser}</CreatedUser>'
        '<CreatedDate>${notification.createdDate}</CreatedDate>'
        '<Completed>${notification.completed}</Completed>'
        '<Type>${notification.type}</Type>'
        '<PinAlanDet>${notification.pinAlanDet}</PinAlanDet>'
        '<PinAlan>${notification.pinAlan}</PinAlan>'
        '</notification>';

    final Response response =
        await WebService.sendRequest('AddNotification', dataXML);

    if (response.isConnected) {
      final bool result = response.result.single
                  .findElements('IsSuccessful')
                  .single
                  .innerText ==
              'true'
          ? true
          : false;
      return result;
    } else {
      return false;
    }
  }
}
