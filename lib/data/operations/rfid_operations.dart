import 'package:aqromis_application/models/add_tree/alan_rfid.dart';
import 'package:aqromis_application/models/response.dart';
import 'package:aqromis_application/models/rfid_garden_result.dart';
import 'package:aqromis_application/utils/xml_parser.dart';

import '../web_service.dart';
import 'package:xml/xml.dart' as xml;

class RFIDOperations {
  static Future<dynamic> getGardenByRFID(String rfid) async {
    RFIDGardenResult result = RFIDGardenResult(
        minTreeCount: 0, isSuccess: false, maxTreeCount: 0, isOneTree: false);
    String dataXML = '<rfid>$rfid</rfid>';

    final Response response =
        await WebService.sendRequest('GardenFromRFID', dataXML);

    if (response.isConnected) {
      result.isOneTree =
          response.result.single.findElements('IsOneTree').single.innerText ==
                  'true'
              ? true
              : false;

      if (result.isOneTree == false) {
        result.minTreeCount =
            XMLParser.getInteger(response.result, 'MinTreeCount');
        result.maxTreeCount =
            XMLParser.getInteger(response.result, 'MaxTreeCount');
      }
      return result;
    } else {
      return false;
    }
  }

  static Future<dynamic> saveAlanRFID(AlanRFID alanRFID) async {
    String dataXML = '<alanRFID>'
        '<RFID>${alanRFID.rfid}</RFID>'
        '<PinAlan>${alanRFID.pinalan}</PinAlan>'
        '<PinBitkiCesid>${alanRFID.pinbitkicesid}</PinBitkiCesid>'
        '</alanRFID>';

    final Response response =
        await WebService.sendRequest('SaveAlanRFID', dataXML);

    if (response.isConnected) {
      if (response.result.single
              .findElements('IsSuccessful')
              .single
              .innerText ==
          'true') {
        return 'true';
      } else if (response.result.single
              .findElements('ErrorMessage')
              .single
              .innerText ==
          'Bu etiket artıq tanımlanıb!') {
        return response.result.single
            .findElements('ErrorMessage')
            .single
            .innerText;
      } else {
        return 'Server xətası baş verdi!';
      }
    } else {
      return 'Bağlantı xətası verdi!';
    }
  }
}
