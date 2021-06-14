import 'package:aqromis_application/models/app_info.dart';
import 'package:aqromis_application/models/response.dart';
import 'package:aqromis_application/utils/xml_parser.dart';

import '../web_service.dart';

class AppOperations{
  static Future<dynamic> getAppInfo(int userId) async {
    AppInfo info = AppInfo();
    String dataXML = "<userPin>$userId</userPin>";

    final Response response = await WebService.sendRequest("AppInformation", dataXML);
    if(response.isConnected){

      info.userTaskCount = XMLParser.getInteger(response.result, "UserTaskCount");
      info.name = XMLParser.getString(response.result, "Name");
      info.version = XMLParser.getDouble(response.result, "Version");
      info.updatedDate = XMLParser.getString(response.result, "UpdatedDate");
      info.downloadLink = XMLParser.getString(response.result, "DownloadLink");
      info.developerName = XMLParser.getString(response.result, "DeveloperName");
      info.developerEmail = XMLParser.getString(response.result, "DeveloperEmail");
      info.developerSite = XMLParser.getString(response.result, "DeveloperSite");
      info.developerPhone = XMLParser.getString(response.result, "DeveloperPhone");

      return info;
    } else{
      return false;
    }
  }
}