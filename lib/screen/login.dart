import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genesis_travels/code/auth.dart';
import 'package:genesis_travels/code/constants.dart';
import 'package:sms_autofill/sms_autofill.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FocusNode textFocus = new FocusNode();
  TextEditingController phoneController = new TextEditingController();
  bool showed = false;

  Future fetchPhoneNumber() async {
    if (!showed) {
      showed = true;
      await Future.delayed(Duration(milliseconds: 200));
      if (this.mounted) {
        var requestNumber = await SmsAutoFill().hint;
        if (requestNumber != null) {
          var number = requestNumber.substring(3, requestNumber.length);
          phoneController.text = number;
        }
      }
    }
  }

  showSnack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: appColor,
    ));
  }

  Future requestOTP() async {
    if (phoneController.text != null) {
      if (phoneController.text.length == 10) {
        textFocus.unfocus();
        authService.signInWithNumber(context, phoneController.text);
      } else {
        showSnack(context, 'Enter a valid phone number');
      }
    } else {
      showSnack(context, 'Enter a valid phone number');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPhoneNumber();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 64),
                  child: Image.asset(
                'assets/logo_travels.png',
                fit: BoxFit.contain,
              )),
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      'Driver/Admin Portal',
                      style: Theme.of(context).textTheme.headline5,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      'Continue with your phone number',
                      style: Theme.of(context).textTheme.headline6,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextField(
                      controller: phoneController,
                      focusNode: textFocus,
                      decoration: textFieldDecoration.copyWith(
                        hintText: 'Phone Number',
                        prefix: Text("+91 "),
                        prefixStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                        ),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      style: TextStyle(
                        fontSize: 15.0,
                      ),
                      // onTap: () {
                      //   fetchPhoneNumber();
                      // },
                      onSubmitted: (value) {
                        requestOTP();
                      },
                    ),
                    Container(
                      width: width,
                      padding: EdgeInsets.only(top: 8),
                      child: TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(appColor),
                              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)))),
                          onPressed: () {
                            requestOTP();
                          },
                          child: Container(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                'Login',
                                style: TextStyle(color: appWhite, fontSize: 18),
                              ))),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
