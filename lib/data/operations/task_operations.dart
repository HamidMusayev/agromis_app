import 'package:aqromis_application/models/response.dart';
import 'package:aqromis_application/models/task.dart';
import 'package:aqromis_application/models/user.dart';
import 'package:uhf_c72_plugin/tag_epc.dart';
import 'package:xml/xml.dart' as xml;

import '../shared_prefs.dart';
import '../web_service.dart';

class TaskOperations{
  static Future<dynamic> getTaskList(bool onlyCompleteds) async {
    final List<Task> tasks = [];
    User user = User.fromJson(await SharedData.readJson("user"));
    final String dataXML = "<userPin>${user.id}</userPin>"
        "<onlyCompleteds>$onlyCompleteds</onlyCompleteds>";

    final Response response = await WebService.sendRequest("TaskList", dataXML);

    if(response.isConnected){
      response.result.single.findAllElements("Task").forEach((element) {
        tasks.add(Task(
            int.parse(element.findElements("Pin").single.innerText),
            int.parse(element.findElements("TypePin").single.innerText),
            int.parse(element.findElements("GardenPin").single.innerText),
            int.parse(element.findElements("CreatedUserPin").single.innerText),
            int.parse(element.findElements("ReadedRFIDCount").single.innerText),
            int.parse(element.findElements("ReadState").single.innerText),
            element.findElements("StartDate").single.innerText,
            element.findElements("EndDate").single.innerText,
            element.findElements("Name").single.innerText,
            element.findElements("Type").single.innerText,
            element.findElements("Description").single.innerText,
            element.findElements("GardenName").single.innerText,
            element.findElements("CreatedUser").single.innerText));
      });

      return tasks;
    } else{
      return false;
    }
  }

  static Future<bool> addTask(Task task, User user) async {
    final String dataXML = "<task>"
        "<PinTask>0</PinTask>"
        "<TypePin>${task.typeId}</TypePin>"
        "<GardenPin>${task.gardenId}</GardenPin>"
        "<CreatedUserPin>${user.id}</CreatedUserPin>"
        "<ReadedRFIDCount>0</ReadedRFIDCount>"
        "<ReadState>0</ReadState>"
        "<StartDate>empty</StartDate>"
        "<EndDate>empty</EndDate>"
        "<Name>${task.name}</Name>"
        "<Type>empty</Type>"
        "<Description>${task.description}</Description>"
        "<GardenName>empty</GardenName>"
        "<CreatedUser>empty</CreatedUser>"
        "</task>";

    final Response response = await WebService.sendRequest("AddTask", dataXML);

    if(response.isConnected){
      final bool result = response.result.single.findElements("IsSuccessful").single.innerText == "true" ? true : false;
      return result;
    } else{
      return false;
    }
  }

  static Future<bool> changeTaskState(int taskId, int readState) async {
    final String dataXML = "<taskId>$taskId</taskId>"
        "<readState>$readState</readState>";

    final Response response = await WebService.sendRequest("ChangeTaskState", dataXML);

    if(response.isConnected){
      final bool result = response.result.single.findElements("IsSuccessful").single.innerText == "true" ? true : false;
      return result;
    } else {
      return false;
    }
  }

  static Future<bool> addRFIDToTask(Task task, List<TagEpc> rfids) async {
    User user = User.fromJson(await SharedData.readJson("user"));

    var builder = new xml.XmlBuilder();
    builder.element('task', nest: (){
      builder.element('TaskPin', nest: task.id);
      builder.element('TypePin', nest: task.typeId);
      builder.element('UserPin', nest: user.id);
      builder.element('GpsData', nest: "gpsData");
      builder.element('RFIDList', nest: (){
        rfids.forEach((element) {
          builder.element('string', nest: element.epc.substring(4));
        });
      });
    });

    final String dataXml = builder.buildDocument().toString();

    final Response response = await WebService.sendRequest("SendRFIDToTask", dataXml);

    if(response.isConnected){
      final bool result = response.result.single.findElements("IsSuccessful").single.innerText == "true" ? true : false;
      return result;
    } else {
      return false;
    }
  }
}