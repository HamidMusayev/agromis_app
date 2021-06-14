import 'package:aqromis_application/models/agronom.dart';
import 'package:aqromis_application/models/garden.dart';
import 'package:aqromis_application/models/response.dart';
import 'package:aqromis_application/models/task_type.dart';

import '../web_service.dart';
import 'package:xml/xml.dart' as xml;

class ListOperations {
  static Future<dynamic> getAgronomList() async {
    final List<Agronom> agronoms = [];
    final String dataXML = "";

    final Response response = await WebService.sendRequest("AgronomList", dataXML);

    if(response.isConnected){
      response.result.single.findAllElements("Agronom").forEach((element) {
        agronoms.add(Agronom(
            int.parse(element.findElements("UserPin").single.innerText),
            int.parse(element.findElements("Pin").single.innerText),
            element.findElements("Username").single.innerText));
      });

      return agronoms;
    } else{
      return false;
    }
  }

  static Future<dynamic> getGardenList() async {
    List<Garden> gardens = [];
    String dataXML = " ";

    final Response response = await WebService.sendRequest("GardenList", dataXML);

    if(response.isConnected){
      response.result.single.findAllElements("Garden").forEach((element) {
        gardens.add(Garden(
            int.parse(element.findElements("Pin").single.innerText),
            element.findElements("Name").single.innerText,
            int.parse(element.findElements("PinArea").single.innerText),
            int.parse(element.findElements("PinPlant").single.innerText),
            element.findElements("PlantName").single.innerText,
            int.parse(element.findElements("PinPlantType").single.innerText)));
      });

      return gardens;
    } else{
      return false;
    }
  }

  static Future<dynamic> getTaskTypeList() async {
    List<TaskType> taskTypes = [];
    String dataXML = " ";

    final Response response = await WebService.sendRequest("TaskTypeList", dataXML);

    if(response.isConnected){
      response.result.single.findAllElements("TaskType").forEach((element) {
        taskTypes.add(TaskType(
            int.parse(element.findElements("Pin").single.innerText),
            element.findElements("Name").single.innerText));
      });

      return taskTypes;
    } else{
      return false;
    }
  }
}
