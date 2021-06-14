class SendDataDB{
  int pinData;
  String methodName;
  String sendDataXml;
  int isSend;

  SendDataDB({this.pinData, this.methodName, this.sendDataXml, this.isSend});

  SendDataDB.fromMap(dynamic o) {
    this.pinData = o["PIN_DATA"];
    this.methodName = o["METHOD_NAME"];
    this.sendDataXml = o["SEND_XML"];
    this.isSend = o["IS_SEND"];
  }
}