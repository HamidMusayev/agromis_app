import 'package:xml/xml.dart' as xml;

class Response{
  bool isConnected;
  Iterable<xml.XmlElement> result;

  Response({required this.isConnected, required this.result});
}