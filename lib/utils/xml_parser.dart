import 'package:xml/xml.dart' as xml;

class XMLParser{
  static int getInteger(Iterable<xml.XmlElement> xml, String elementName){
    return int.parse(xml.single.findElements(elementName).single.innerText);
  }

  static double getDouble(Iterable<xml.XmlElement> xml, String elementName){
    return double.parse(xml.single.findElements(elementName).single.innerText);
  }

  static String getString(Iterable<xml.XmlElement> xml, String elementName){
    return xml.single.findElements(elementName).single.innerText;
  }
}