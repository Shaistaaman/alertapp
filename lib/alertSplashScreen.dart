import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

import 'contactsMangement/addContacts.dart';
import 'login.dart';

class AlertSplashScreen extends StatefulWidget {
  @override
  _AlertSplashScreenState createState() => _AlertSplashScreenState();
}

class _AlertSplashScreenState extends State<AlertSplashScreen> {
  Future authCheck() async {
    FirebaseUser _user = await FirebaseAuth.instance.currentUser();
    return _user;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return SplashScreen(
      gradientBackground: RadialGradient(
        center: Alignment(0, -height * 0.0005),
        radius: 1,
        colors: [
          Color(0xff015597),
          Color(0xff015597),
          Color(0xff002262),
          Color(0xff002262)
        ],
      ),
      photoSize: MediaQuery.of(context).size.height * .25,
      seconds: 2,
      image: Image.asset(
        'assets/new.png',
        fit: BoxFit.contain,
      ),
      loaderColor: Colors.white,
      loadingText: Text(
        "Multi Telesoft Pvt Ltd.",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
      navigateAfterSeconds: FutureBuilder(
        future: authCheck(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return Login();
          } else {
            return AddContacts(user: snapshot.data);
          }
        },
      ),
    );
  }
}
