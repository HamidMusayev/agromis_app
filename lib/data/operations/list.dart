import 'package:aqromis_application/models/add_tree/alan.dart';
import 'package:aqromis_application/models/add_tree/bitkicesit.dart';
import 'package:aqromis_application/models/add_tree/bitkitur.dart';
import 'package:aqromis_application/models/agronom.dart';
import 'package:aqromis_application/models/garden.dart';
import 'package:aqromis_application/models/response.dart';
import 'package:aqromis_application/models/task_type.dart';
import 'package:aqromis_application/models/treeinfo/tree_notification.dart';

import '../../models/add_tree/alandet.dart';
import '../web_service.dart';
import 'package:xml/xml.dart' as xml;

class ListOperations {
  static Future<dynamic> getAgronomList() async {
    final List<Agronom> agronoms = [];
    const String dataXML = '';

    final Response response =
        await WebService.sendRequest('AgronomList', dataXML);

    if (response.isConnected) {
      response.result.single.findAllElements('Agronom').forEach((element) {
        agronoms.add(
          Agronom(
            int.parse(element.findElements('UserPin').single.innerText),
            int.parse(element.findElements('Pin').single.innerText),
            element.findElements('Username').single.innerText,
          ),
        );
      });

      return agronoms;
    } else {
      return false;
    }
  }

  static Future<dynamic> getGardenList() async {
    List<Garden> gardens = [];
    String dataXML = '';

    final Response response =
        await WebService.sendRequest('GardenList', dataXML);

    if (response.isConnected) {
      response.result.single.findAllElements('Garden').forEach((element) {
        gardens.add(
          Garden(
            int.parse(element.findElements('Pin').single.innerText),
            element.findElements('Name').single.innerText,
            int.parse(element.findElements('PinArea').single.innerText),
            int.parse(element.findElements('PinPlant').single.innerText),
            element.findElements('PlantName').single.innerText,
            int.parse(
              element.findElements('PinPlantType').single.innerText,
            ),
          ),
        );
      });

      return gardens;
    } else {
      return false;
    }
  }

  static Future<dynamic> getTaskTypeList() async {
    List<TaskType> taskTypes = [];
    String dataXML = ' ';

    final Response response =
        await WebService.sendRequest('TaskTypeList', dataXML);

    if (response.isConnected) {
      response.result.single.findAllElements('TaskType').forEach((element) {
        taskTypes.add(
          TaskType(int.parse(element.findElements('Pin').single.innerText),
              element.findElements('Name').single.innerText),
        );
      });

      return taskTypes;
    } else {
      return false;
    }
  }

  static Future<dynamic> getAlanList(String pinxbag) async {
    final List<Alan> alans = [];
    String dataXML = '<pinxbag>$pinxbag</pinxbag>';

    final Response response = await WebService.sendRequest('AlanList', dataXML);

    if (response.isConnected) {
      response.result.single.findAllElements('Alan').forEach((element) {
        alans.add(
          Alan(
            element.findElements('PinAlan').single.innerText,
            element.findElements('AlanName').single.innerText,
            element.findElements('PinBitkiCesid').single.innerText,
            element.findElements('RFID').single.innerText,
          ),
        );
      });

      return alans;
    } else {
      return false;
    }
  }

  static Future<dynamic> getAlanDetList(String pinalan) async {
    final List<AlanDet> alandets = [];
    String dataXML = '<pinalan>$pinalan</pinalan>';

    final Response response =
        await WebService.sendRequest('AlanDetList', dataXML);

    if (response.isConnected) {
      response.result.single.findAllElements('AlanDet').forEach((element) {
        alandets.add(
          AlanDet(
            element.findElements('PinAlanDet').single.innerText,
            element.findElements('PinABitki').single.innerText,
            element.findElements('Epc').single.innerText,
            element.findElements('PinABitkiTur').single.innerText,
            element.findElements('PinABitkiCesit').single.innerText,
          ),
        );
      });

      return alandets;
    } else {
      return false;
    }
  }

  static Future<dynamic> getBitkiCesitList() async {
    final List<BitkiCesit> bitkicesids = [];
    const String dataXML = '';

    final Response response =
        await WebService.sendRequest('BitkiCesitList', dataXML);

    if (response.isConnected) {
      response.result.single.findAllElements('BitkiCesit').forEach((element) {
        bitkicesids.add(
          BitkiCesit(
            element.findElements('PinBitkiCesit').single.innerText,
            element.findElements('BitkiCesitName').single.innerText,
          ),
        );
      });

      return bitkicesids;
    } else {
      return false;
    }
  }

  static Future<dynamic> getBitkiTurList() async {
    final List<BitkiTur> bitkiturs = [];
    const String dataXML = '';

    final Response response =
        await WebService.sendRequest('BitkiTurList', dataXML);

    if (response.isConnected) {
      response.result.single.findAllElements('BitkiTur').forEach((element) {
        bitkiturs.add(
          BitkiTur(
            element.findElements('PinBitkiTur').single.innerText,
            element.findElements('BitkiTurName').single.innerText,
          ),
        );
      });

      return bitkiturs;
    } else {
      return false;
    }
  }

  static Future<dynamic> getNotificationList(
      String rfid, String pinAlanDet, bool isRfid, bool isAll) async {
    final List<TreeNotification> notifications = [];
    String dataXML = '<rfid>$rfid</rfid>'
        '<pinAlanDet>$pinAlanDet</pinAlanDet>'
        '<isRfid>$isRfid</isRfid>'
        '<isAll>$isAll</isAll>';

    final Response response =
        await WebService.sendRequest('TreeNotificationList', dataXML);

    if (response.isConnected) {
      response.result.single
          .findAllElements('TreeNotification')
          .forEach((element) {
        notifications.add(
          TreeNotification(
            int.parse(element.findElements('PinNotification').single.innerText),
            element.findElements('Title').single.innerText,
            element.findElements('Description').single.innerText,
            element.findElements('CreatedUserCode').single.innerText,
            element.findElements('CreatedUser').single.innerText,
            element.findElements('CreatedDate').single.innerText,
            int.parse(element.findElements('Type').single.innerText),
            int.parse(element.findElements('Completed').single.innerText),
          ),
        );
      });

      return notifications;
    } else {
      return false;
    }
  }
}
