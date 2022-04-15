import 'package:aqromis_application/constants.dart';
import 'package:aqromis_application/text_constants.dart' as Constants;

class TextValidator{
  String? validateEmail(String text){
    return text.isEmpty ? Constants.tEmailNullError : emailValidatorRegExp.hasMatch(text) ? null : Constants.tInvalidEmailError;
  }

  String? validatePassword(String text){
    return text.isEmpty ? Constants.tPassNullError : text.length < 5 ?  Constants.tShortPassError : null;
  }

  String? validateName(String text){
    return text.isEmpty ? Constants.tNameNullError : text.length < 3 ? Constants.tNameShortError : null;
  }

  String? validateSurname(String text){
    return text.isEmpty ? Constants.tSurnameNullError : text.length < 3 ? Constants.tSurnameShortError : null;
  }

  String? validateTreeCount(String text, int min, int max){
    return int.parse(text) < min || int.parse(text) > max ? 'Nömrə ' + min.toString() + '-' + max.toString() +' aralığında olmalıdır' : null;
  }
}