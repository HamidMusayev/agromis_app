import 'dart:io';
import 'package:aqromis_application/data/local_db.dart';
import 'package:aqromis_application/models/response.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

import 'local_send_db.dart';

class WebService{
  static Future<Response> sendRequest(String methodName, String sendDataXML) async {
    var uri;
    if (kIsWeb) {
      uri = Uri.parse("http://localhost:8081/agromis/agromisservice/service.asmx");
    } else {
      uri = Uri.parse("http://194.135.95.23:8081/agromis/agromisservice/service.asmx");
    }

    Response response = Response(isConnected: true);

    final envelope = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
          "<soap:Body>"
            "<$methodName xmlns=\"https://hisaz.az/\">"
              "$sendDataXML"
            "</$methodName>"
          "</soap:Body>"
        "</soap:Envelope>";

    try{
      final responseXML = await http.post(
        uri,
        headers: {
          //"Access-Control-Allow-Origin": "*",
          "Content-Type": "text/xml; charset=utf-8",
          "SOAPAction": "https://hisaz.az/$methodName",
          "Host": "localhost",
          "Accept": "text/xml"
        },
        body: envelope,
      );

      response.result = xml.XmlDocument.parse(responseXML.body).findAllElements("${methodName}Result");

      await LocalDB().updateOrInsert(methodName, sendDataXML, responseXML.body);

      //final responseDoc = xml.XmlDocument.parse(responseXML.body);
      //print(responseDoc.toXmlString(pretty: true, indent: '\t'));

    } on SocketException {
      print("No Internet connection 😑");

      if(methodName == "ChangeTaskState" || methodName == "SendRFIDToTask" || methodName == "SendRequest"){
        await LocalSendDB().insert(methodName, sendDataXML);
        response.result = xml.XmlDocument.parse("<body><IsSuccessful>true</IsSuccessful></body>").findAllElements("body");
      } else if(methodName == "UserRegister" || methodName == "UserLogin" || methodName == "AddTask"){
        response.isConnected = false;
      } else {
        await LocalDB().getData(methodName, sendDataXML).then((value) => response.result = xml.XmlDocument.parse(value).findAllElements("${methodName}Result"));
      }

    } on HttpException {
      print("Couldn't find the post 😱");
    } on FormatException {
      print("Bad response format 👎");
    }

    return response;
  }


}