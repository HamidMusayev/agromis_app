class SendDataDB {
  late int pinData;
  late String methodName;
  late String sendDataXml;
  late int isSend;

  SendDataDB(
      {required this.pinData,
      required this.methodName,
      required this.sendDataXml,
      required this.isSend});

  SendDataDB.fromMap(dynamic o) {
    pinData = o['PIN_DATA'];
    methodName = o['METHOD_NAME'];
    sendDataXml = o['SEND_XML'];
    isSend = o['IS_SEND'];
  }
}
