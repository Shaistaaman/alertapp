import 'package:com/alertSuccess.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'alertSplashScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff015597),
        backgroundColor: Color(0xff015597),
      ),
      home: AlertSplashScreen(),
      routes: {
        '/alertSuccess': (context) => AlertSuccess()
      },
    );
  }
}

