import 'package:aqromis_application/models/response.dart';
import 'package:aqromis_application/models/rfid_garden_result.dart';
import 'package:aqromis_application/utils/xml_parser.dart';

import '../web_service.dart';
import 'package:xml/xml.dart' as xml;

class RFIDOperations {
  static Future<dynamic> getGardenByRFID(String rfid) async {
    RFIDGardenResult result = RFIDGardenResult();
    String dataXML = "<rfid>$rfid</rfid>";

    final Response response = await WebService.sendRequest("GardenFromRFID", dataXML);

    if(response.isConnected){
      result.isOneTree = response.result.single.findElements("IsOneTree").single.innerText == "true" ? true : false;

      if (result.isOneTree == false) {
        result.minTreeCount = XMLParser.getInteger(response.result, "MinTreeCount");
        result.maxTreeCount = XMLParser.getInteger(response.result, "MaxTreeCount");
      }
      return result;
    } else{
      return false;
    }
  }
}
