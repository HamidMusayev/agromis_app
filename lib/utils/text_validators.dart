import 'package:aqromis_application/constants.dart';
import 'package:aqromis_application/text_constants.dart' as constants;

class TextValidator{
  String? validateEmail(String text){
    return text.isEmpty ? constants.tEmailNullError : emailValidatorRegExp.hasMatch(text) ? null : constants.tInvalidEmailError;
  }

  String? validatePassword(String text){
    return text.isEmpty ? constants.tPassNullError : text.length < 5 ?  constants.tShortPassError : null;
  }

  String? validateName(String text){
    return text.isEmpty ? constants.tNameNullError : text.length < 3 ? constants.tNameShortError : null;
  }

  String? validateSurname(String text){
    return text.isEmpty ? constants.tSurnameNullError : text.length < 3 ? constants.tSurnameShortError : null;
  }

  String? validateTreeCount(String text, int min, int max){
    return int.parse(text) < min || int.parse(text) > max ? 'Nömrə $min-$max aralığında olmalıdır' : null;
  }
}