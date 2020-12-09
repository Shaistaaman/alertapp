import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

class AlertSuccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return SplashScreen(
      gradientBackground: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xff015597),
            Color(0xff015597),
            Color(0xff002262),
            Color(0xff002262),
          ]),
      photoSize: height * 0.27,
      seconds: 1,
      image: Image.asset(
        'assets/alertlogo.png',
        fit: BoxFit.cover,
        width: width * 0.5,
      ),
      loaderColor: Colors.white,
      loadingText: Text("Sending to Contacts...",
          style: TextStyle(fontFamily: 'Sogoe', color: Colors.white)),
      title: Text(
        "Alerts are being delivered\nStay Calm! ",
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: 'Sogoe', color: Colors.white, fontSize: height * 0.03),
      ),
      navigateAfterSeconds: poppingOut(context),
    );
  }

  poppingOut(BuildContext context) {
    Future.delayed(Duration(seconds: 5), () {
      int count = 0;
      Navigator.of(context).popUntil((_) => count++ >= 2);
    });
  }
}
