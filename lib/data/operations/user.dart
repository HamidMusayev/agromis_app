import 'package:aqromis_application/models/response.dart';
import 'package:aqromis_application/models/user.dart';
import 'package:xml/xml.dart' as xml;
import '../shared_prefs.dart';
import '../web_service.dart';

class UserOperations {
  static Future<bool> registerUser(User user) async {
    String dataXML = '<user>'
        '<Name>${user.name}</Name>'
        '<Surname>${user.surname}</Surname>'
        '<Email>${user.email}</Email>'
        '<Password>${user.password}</Password>'
        '</user>';

    final Response response = await WebService.sendRequest('UserRegister', dataXML);
    if(response.isConnected){
      bool res = response.result.single.findElements('IsSuccessful').single.innerText == 'true'
          ? true
          : false;

      return res;
    }
    return false;
  }

  static Future<bool> loginUser(User user, bool isLoginSave) async {
    String dataXML = '<user>'
        '<Name>${user.name}</Name>'
        '<Surname>${user.surname}</Surname>'
        '<Email>${user.email}</Email>'
        '<Password>${user.password}</Password>'
        '</user>';

    final Response response = await WebService.sendRequest('UserLogin', dataXML);
    if(response.isConnected){
      bool res = response.result.single.findElements('IsSuccessful').single.innerText == 'true'
          ? true
          : false;

      if(res){
        user.id = int.parse(response.result.single.findElements('Pin').single.innerText);
        user.name = response.result.single.findElements('UserName').single.innerText;
        SharedData.saveJson('user', user);
        SharedData.setBool('isLoginSave', isLoginSave);
      }

      return res;
    }
    return false;
  }
}
