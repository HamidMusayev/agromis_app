import 'package:aqromis_application/data/operations/user_operations.dart';
import 'package:aqromis_application/models/user.dart';
import 'package:aqromis_application/screens/home.dart';
import 'package:aqromis_application/screens/sign_up.dart';
import 'package:aqromis_application/utils/text_validators.dart';
import 'package:aqromis_application/widgets/default_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../constants.dart';
import '../size_config.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool animate = false;
  bool isLoginSave = false;
  bool isLoading = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailTxt = TextEditingController();
  TextEditingController passwordTxt = TextEditingController();

  List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
  ];

  @override
  void initState() {
    Future.delayed(Duration(seconds: 0), () {
      setState(() =>animate = true);
    });
    _focusNodes.forEach((node) {
      node.addListener(() {
        setState(() {});
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double space = getProportionateScreenHeight(70.0);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: kDefaultPadding,
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: space),
              Text("DAXİL OL", style: headingStyle),
              buildLine(),
              Text("   Hesabınız varsa, daxil olun"),
              SizedBox(height: space * 2),
              buildFormField(formKey),
              Row(
                children: <Widget>[
                  Checkbox(
                      value: isLoginSave,
                      activeColor: kPrimaryColor,
                      onChanged: (value) => setState(() => isLoginSave = value)),
                  Text("Yadda saxla", style: semibold14Style),

                  // Spacer(),
                  // Text("Şifrəni unutdun?    ", style: TextStyle(fontWeight: FontWeight.w600))
                ],
              ),
              Spacer(),
              Container(
                alignment: Alignment.center,
                child: isLoading ? Center(child: Lottie.asset("assets/lottie/loading_small.json", width: getProportionateScreenWidth(100.0))) : DefaultButton(
                    text: "Daxil ol",
                    backColor: kPrimaryColor,
                    textColor: kWhiteColor,
                    onPress: () {
                      if (formKey.currentState.validate()) {
                        setState(() => isLoading = true);
                        UserOperations.loginUser(User("", "", emailTxt.text.trim(), passwordTxt.text), isLoginSave).then((value) => value
                            ? Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()))
                            : showAlert(),
                        );
                      }
                    }),
              ),
              SizedBox(height: getProportionateScreenHeight(10.0)),
              DefaultButton(
                  text: "Hesab yarat",
                  backColor: kSecondaryColor,
                  textColor: kPrimaryColor,
                  onPress: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()))),
            ],
          ),
        ),
      ),
    );
  }

  AnimatedContainer buildLine() {
    return AnimatedContainer(
      duration: kAnimationDuration,
      margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
      height: 6,
      width: animate ? getProportionateScreenWidth(70.0) : 0,
      decoration: BoxDecoration(
        color: kSecondaryColor,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  buildFormField(GlobalKey<FormState> key) {
    SizeConfig().init(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Form(
          key: key,
          child: Column(
            children: <Widget>[
              TextFormField(
                  validator: (val) => TextValidator().validateEmail(val),
                  controller: emailTxt,
                  focusNode: _focusNodes[0],
                  decoration: InputDecoration(
                      hintText: "E-mail",
                      prefixIcon: Icon(Icons.email,
                          color: _focusNodes[0].hasFocus
                              ? kPrimaryColor
                              : kInputTextColor))),
              SizedBox(height: getProportionateScreenHeight(10.0)),
              TextFormField(
                  obscureText: true,
                  validator: (val) => TextValidator().validatePassword(val),
                  controller: passwordTxt,
                  focusNode: _focusNodes[1],
                  decoration: InputDecoration(
                      hintText: "Şifrə",
                      prefixIcon: Icon(Icons.lock,
                          color: _focusNodes[1].hasFocus
                              ? kPrimaryColor
                              : kInputTextColor))),
            ],
          ),
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(kDefaultRadius)),
        title: Column(
          children: <Widget>[
            Icon(Icons.error_rounded, color: kRedColor, size: 50.0),
            SizedBox(height: 12.0),
            Text("Xəta baş verdi!", textAlign: TextAlign.center),
            Text("- Hesabınız olduğundan əmin olun\n- Email və şifrənin düzgünlüyünü yoxlayın\n- Hesabınızın təsdiqləndiyindən əmin olun", textAlign: TextAlign.left, style: light14Style),
          ],
        ),
      ),
    );
  }
}
