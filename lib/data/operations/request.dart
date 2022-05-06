import 'package:aqromis_application/models/request.dart';
import 'package:aqromis_application/models/response.dart';

import '../web_service.dart';
import 'package:xml/xml.dart' as xml;

class RequestOperations {
  static Future<bool> sendRequest(Request request) async {
    String dataXML = '<request>'
      '<CreateUser>${request.createusercode}</CreateUser>'
      '<IsOneTree>${request.isonetree}</IsOneTree>'
      '<InfoType>${request.infotype}</InfoType>'
      '<Title>${request.title}</Title>'
      '<Description>${request.description}</Description>'
      '<Epc>${request.epc}</Epc>'
      '<IsAllSelected>${request.isselectedall}</IsAllSelected>'
      '<Pictures>'
        '<string>${request.pictures[0]}</string>'
        '<string>${request.pictures[1]}</string>'
        '<string>${request.pictures[2]}</string>'
        '<string>${request.pictures[3]}</string>'
        '<string>${request.pictures[4]}</string>'
      '</Pictures>'
      '<SelectedTrees>'
        '<int>${request.selectedtrees==null ? 0 : request.selectedtrees[0]}</int>'
      '</SelectedTrees>'
      '<AreaDetPin>0</AreaDetPin>'
    '</request>';

    final Response response = await WebService.sendRequest('SendRequest', dataXML);

    if(response.isConnected){
      final bool result = response.result.single.findElements('IsSuccessful').single.innerText == 'true' ? true : false;
      return result;
    } else{
      return false;
    }
  }
}
