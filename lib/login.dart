import 'package:com/contactsMangement/addContacts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:com/Animation/bottomAnimation.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

final _controllerPhone = TextEditingController();
final _controllerCode = TextEditingController();

class _LoginState extends State<Login> {
  bool validate = false;
  bool codeValidate = false;
  String _verificationId;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                Color(0xff015597),
                Color(0xff015597),
                Color(0xff002262),
                Color(0xff002262),
              ])),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: height * 0.07,
                  ),
                  Image.asset(
                    'assets/alertlogo.png',
                    height: height * 0.25,
                  ),
                  SizedBox(
                    height: height * 0.1,
                  ),
                  phoneTextField(width, height),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.info,
                        color: Colors.blue,
                        size: height * 0.03,
                      ),
                      SizedBox(
                        width: width * 0.02,
                      ),
                      RichText(
                          text: TextSpan(children: [
                        TextSpan(text: 'We will send'),
                        TextSpan(
                          text: ' One Time Password',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' on \nthis mobile number')
                      ])),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.05,
                  ),
                  loginBtn(width, height),
                  SizedBox(
                    height: height * 0.17,
                  ),
                  Text(
                    "Multi Telesoft Pvt Ltd.",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String validatePhone(String phone) {
    if (!(phone.length == 10) && phone.isNotEmpty) {
      return "Invalid Phone Number length";
    }
    return null;
  }

  String validateCode(String code) {
    if (!(code.length == 6) && code.isNotEmpty) {
      return "Invalid Code length";
    }
    return null;
  }

  verificationCompleted() {
    return (AuthCredential credential) async {
      await _auth.signInWithCredential(credential).then((AuthResult value) {
        if (value.user != null) {
          Navigator.pop(context);
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => AddContacts(
                        user: value.user,
                      )));
        }
      });
    };
  }

  verificationFailed() {
    return (AuthException exception) {
      Toast.show('Verification Failed: ${exception.code}', context,
          backgroundColor: Colors.red,
          duration: 3,
          backgroundRadius: 5,
          gravity: Toast.BOTTOM);
    };
  }

  codeSent() {
    return (String verificationID, [int forceResendingToken]) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: Text('Enter 6-Digit Code'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.025),
                    controller: _controllerCode,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      errorText: validateCode(_controllerCode.text),
                      hintText: 'Enter Code',
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: Colors.red)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: Colors.red)),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.info,
                        color: Colors.red,
                        size: MediaQuery.of(context).size.height * 0.03,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.02,
                      ),
                      Text(
                        'Wait for Automatic Detection!',
                        style: TextStyle(
                            fontFamily: 'Sogoe',
                            color: Colors.red,
                            fontSize:
                                MediaQuery.of(context).size.height * 0.017),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.06,
                    width: MediaQuery.of(context).size.width,
                    child: FlatButton(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * .05),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      child: Text("Confirm",),
                      textColor: Colors.white,
                      color: Colors.lightBlue,
                      onPressed: () async {
                        setState(() {
                          _controllerCode.text.isEmpty
                              ? codeValidate = true
                              : codeValidate = false;
                        });
                        _auth.currentUser().then((user) {
                          if (user != null) {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddContacts(
                                          user: user,
                                        )));
                          } else {
                            _verifyCode();
                          }
                        });
                        _controllerCode.clear();
                      },
                    ),
                  )
                ],
              ),
            );
          });
      _verificationId = verificationID;
    };
  }

  codeAutoRetrievalTimeout() {
    return (String verificationID) {
      _verificationId = verificationID;
    };
  }

  Future<void> _verifyPhoneNumber(String phone) async {
    _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: verificationCompleted(),
      verificationFailed: verificationFailed(),
      codeSent: codeSent(),
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout(),
    );
  }

  Future<void> _verifyCode() async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: _verificationId, smsCode: _controllerCode.text);
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    if (user != null) {
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddContacts(
                    user: user,
                  )));
    }
  }

  Widget phoneTextField(double mediaQueryWidth, double mediaQueryHeight) {
    return Container(
      width: mediaQueryWidth * 0.9,
      child: TextField(
          controller: _controllerPhone,
          style: TextStyle(
              color: Colors.white, fontSize: mediaQueryHeight * 0.023),
          keyboardType: TextInputType.phone,
          autofocus: false,
          cursorColor: Colors.white,
          maxLength: 10,
          decoration: InputDecoration(
              errorText: validatePhone(_controllerPhone.text),
              counterStyle: TextStyle(color: Colors.white),
              prefixIcon: WidgetAnimator(
                Icon(
                  Icons.phone,
                  color: Colors.white,
                  size: mediaQueryHeight * 0.03,
                ),
              ),
              prefix: Text(
                '+92',
                style: TextStyle(fontSize: mediaQueryHeight * 0.023),
              ),
              prefixStyle: TextStyle(color: Colors.white),
              labelText: 'Phone Number',
              labelStyle: TextStyle(color: Colors.white),
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(32)),
              errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(32)),
              focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(32)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(32)))),
    );
  }

  Widget loginBtn(double mediaQueryWidth, double mediaQueryHeight) => Container(
        width: mediaQueryWidth * 0.5,
        height: mediaQueryHeight * 0.07,
        child: FlatButton(
          splashColor: Colors.blue,
          onPressed: () async {
            setState(() {
              _controllerPhone.text.isEmpty
                  ? validate = true
                  : validate = false;
            });
            final phoneNumber = "+92" + _controllerPhone.text.trim();
            _verifyPhoneNumber(phoneNumber);
            _controllerPhone.clear();
          },
          child: WidgetAnimator(
            Text(
              "Login",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          color: Colors.white,
          shape: StadiumBorder(),
        ),
      );
}
