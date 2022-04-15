import 'package:aqromis_application/data/operations/user_operations.dart';
import 'package:aqromis_application/models/user.dart';
import 'package:aqromis_application/screens/sign_in.dart';
import 'package:aqromis_application/utils/text_validators.dart';
import 'package:aqromis_application/widgets/default_button.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../constants.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool animate = false;
  bool isLoading = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController nameTxt = TextEditingController();
  TextEditingController surnameTxt = TextEditingController();
  TextEditingController emailTxt = TextEditingController();
  TextEditingController passwordTxt = TextEditingController();

  final List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 0), () {
      setState(() => animate = true);
    });
    for (var node in _focusNodes) {
      node.addListener(() {
        setState(() {});
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: kDefaultPadding,
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 12),
              const Text('HESAB YARAT', style: headingStyle),
              buildLine(),
              const Text('   Hesabınız yoxdursa, yeni istifadəçi yaradın'),
              const Spacer(),
              buildFormField(formKey),
              const Spacer(),
              Container(
                alignment: Alignment.center,
                child: isLoading
                    ? Center(
                        child: Lottie.asset('assets/lottie/loading_small.json',
                            width: 100))
                    : DefaultButton(
                        text: 'Yarat',
                        backColor: kPrimaryColor,
                        textColor: kWhiteColor,
                        onPress: () {
                          if (formKey.currentState?.validate() ?? false) {
                            setState(() => isLoading = true);
                            UserOperations.registerUser(User(
                                    nameTxt.text,
                                    surnameTxt.text.trim(),
                                    emailTxt.text.trim(),
                                    passwordTxt.text))
                                .then((value) => value
                                    ? Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SignInScreen()))
                                    : showAlert());
                          }
                        }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AnimatedContainer buildLine() {
    return AnimatedContainer(
      duration: kAnimationDuration,
      margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
      height: 6,
      width: animate ? 70 : 0,
      decoration: BoxDecoration(
        color: kSecondaryColor,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  buildFormField(GlobalKey<FormState> key) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: key,
        child: Column(
          children: <Widget>[
            TextFormField(
                validator: (val) => TextValidator().validateName(val ?? ''),
                controller: nameTxt,
                focusNode: _focusNodes[0],
                decoration: InputDecoration(
                    hintText: 'Adınız',
                    prefixIcon: Icon(Icons.person,
                        color: _focusNodes[0].hasFocus
                            ? kPrimaryColor
                            : kInputTextColor))),
            const SizedBox(height: 12),
            TextFormField(
                validator: (val) => TextValidator().validateSurname(val ?? ''),
                controller: surnameTxt,
                focusNode: _focusNodes[1],
                decoration: InputDecoration(
                    hintText: 'Soyadınız',
                    prefixIcon: Icon(Icons.person,
                        color: _focusNodes[1].hasFocus
                            ? kPrimaryColor
                            : kInputTextColor))),
            const SizedBox(height: 12),
            TextFormField(
                validator: (val) => TextValidator().validateEmail(val ?? ''),
                controller: emailTxt,
                focusNode: _focusNodes[2],
                decoration: InputDecoration(
                    hintText: 'E-mail',
                    prefixIcon: Icon(Icons.email,
                        color: _focusNodes[2].hasFocus
                            ? kPrimaryColor
                            : kInputTextColor))),
            const SizedBox(height: 12),
            TextFormField(
                obscureText: true,
                validator: (val) => TextValidator().validatePassword(val ?? ''),
                controller: passwordTxt,
                focusNode: _focusNodes[3],
                decoration: InputDecoration(
                    hintText: 'Şifrə',
                    prefixIcon: Icon(Icons.lock,
                        color: _focusNodes[3].hasFocus
                            ? kPrimaryColor
                            : kInputTextColor))),
          ],
        ),
      ),
    );
  }

  Future<dynamic> showAlert() {
    setState(() => isLoading = false);
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black45,
      builder: (_) => AlertDialog(
        elevation: 0,
        titleTextStyle: semibold14Style,
        contentTextStyle: semibold14Style,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(kDefaultRadius)),
        title: Column(
          children: const <Widget>[
            Icon(Icons.error_rounded, color: kRedColor, size: 50.0),
            SizedBox(height: 12.0),
            Text('Xəta baş verdi!', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
