import 'package:aqromis_application/screens/sign_up.dart';
import 'package:aqromis_application/utils/text_validators.dart';
import 'package:aqromis_application/widgets/default_button.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../constants.dart';
import '../data/operations/user.dart';
import '../models/user.dart';
import 'home.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isLoginSave = false;
  bool isLoading = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailTxt = TextEditingController();
  TextEditingController passwordTxt = TextEditingController();

  final List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
  ];

  @override
  void initState() {
    // for (var node in _focusNodes) {
    //   node.addListener(() {
    //     setState(() {});
    //   });
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: kDefaultPadding,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 12),
              const Text('DAXİL OL', style: headingStyle),
              buildLine(),
              const Text('Hesabınız varsa, daxil olun'),
              const SizedBox(height: 48),
              Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      validator: (val) =>
                          TextValidator().validateEmail(val ?? ''),
                      controller: emailTxt,
                      focusNode: _focusNodes[0],
                      decoration: InputDecoration(
                        hintText: 'E-mail',
                        prefixIcon: Icon(Icons.email,
                            color: _focusNodes[0].hasFocus
                                ? kPrimaryColor
                                : kInputTextColor),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      obscureText: true,
                      validator: (val) =>
                          TextValidator().validatePassword(val ?? ''),
                      controller: passwordTxt,
                      focusNode: _focusNodes[1],
                      decoration: InputDecoration(
                        hintText: 'Şifrə',
                        prefixIcon: Icon(
                          Icons.lock,
                          color: _focusNodes[1].hasFocus
                              ? kPrimaryColor
                              : kInputTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: isLoginSave,
                    activeColor: kPrimaryColor,
                    onChanged: (value) =>
                        setState(() => isLoginSave = value ?? false),
                  ),
                  const Text('Yadda saxla', style: semibold14Style),
                ],
              ),
              const SizedBox(height: 24),
              isLoading
                  ? Center(
                      child: Lottie.asset(
                        'assets/lottie/loading_small.json',
                        width: 100,
                      ),
                    )
                  : DefaultButton(
                      text: 'Daxil ol',
                      backColor: kPrimaryColor,
                      textColor: kWhiteColor,
                      onPress: () {
                        if (formKey.currentState?.validate() ?? false) {
                          setState(() => isLoading = true);
                          UserOperations.loginUser(
                                  User('', '', emailTxt.text.trim(),
                                      passwordTxt.text),
                                  isLoginSave)
                              .then(
                            (value) => value
                                ? Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const HomeScreen()),
                                  )
                                : showAlert(),
                          );
                        }
                      },
                    ),
              const SizedBox(height: 12),
              DefaultButton(
                text: 'Hesab yarat',
                backColor: kSecondaryColor,
                textColor: kPrimaryColor,
                onPress: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container buildLine() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
      height: 6,
      width: 70,
      decoration: BoxDecoration(
        color: kSecondaryColor,
        borderRadius: BorderRadius.circular(3),
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
            Text(
                '- Hesabınız olduğundan əmin olun\n- Email və şifrənin düzgünlüyünü yoxlayın\n- Hesabınızın təsdiqləndiyindən əmin olun',
                textAlign: TextAlign.left,
                style: light14Style),
          ],
        ),
      ),
    );
  }
}
