import 'package:com/model/uploadContact.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:com/Animation/bottomAnimation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sms_maintained/sms.dart';
import 'package:toast/toast.dart';

class LocationOnMap extends StatefulWidget {
  final FirebaseUser user;
  final double initLat;
  final double initLong;

  LocationOnMap({this.user, this.initLat, this.initLong});

  @override
  _LocationOnMapState createState() => _LocationOnMapState();
}

final _controller = TextEditingController();

class _LocationOnMapState extends State<LocationOnMap> {
  final FirebaseDatabase database = new FirebaseDatabase();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    DatabaseReference contactRef =
        database.reference().child(widget.user.phoneNumber);

    final CameraPosition initialPosition = CameraPosition(
        target: LatLng(widget.initLat, widget.initLong), zoom: 18);

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('Maps'),
        ),
        body: SafeArea(
            child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                      Color(0xff015597),
                      Color(0xff015597),
                      Color(0xff002262),
                      Color(0xff002262)
                    ])),
                child: Column(children: <Widget>[
                  SizedBox(height: height * 0.03),
                  topText(width, height),
                  SizedBox(height: height * 0.012),
                  Container(
                    width: width,
                    padding: EdgeInsets.symmetric(horizontal: width * 0.035),
                    height: height * 0.05,
                    child: FirebaseAnimatedList(
                        scrollDirection: Axis.horizontal,
                        query: contactRef,
                        itemBuilder: (BuildContext context,
                            DataSnapshot snapshot,
                            Animation<double> animation,
                            int index) {
                          return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.01),
                              child: contactTile(snapshot, width, height));
                        }),
                  ),
                  SizedBox(height: height * 0.015),
                  Container(
                      width: width * 0.95,
                      height: height * 0.078,
                      child: incidentTextField(height)),
                  Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: width * 0.02, vertical: height * 0.01),
                      width: width,
                      height: height * 0.6,
                      child: Stack(
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                            child: GoogleMap(
                                compassEnabled: true,
                                myLocationEnabled: true,
                                initialCameraPosition: initialPosition,
                                mapType: MapType.normal),
                          ),
                          Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      0, 0, width * 0.02, height * 0.015),
                                  child: FloatingActionButton(
                                      onPressed: () {
                                        if (_controller.text.isEmpty) {
                                          sendAlertToContacts('I need Help!');
                                        } else {
                                          sendAlertToContacts(
                                              _controller.text.trim());
                                          _controller.clear();
                                        }
                                        Future.delayed(Duration(seconds: 3),
                                            () {
                                          Navigator.pushNamed(
                                              context, "/alertSuccess");
                                        });
                                      },
                                      child: WidgetAnimator(Icon(Icons.send,
                                          size: height * 0.035)))))
                        ],
                      ))
                ]))));
  }

  void sendAlert(String number, String msgText) {
    final SmsSender sender = new SmsSender();
    SmsMessage msg = new SmsMessage(number, msgText);
    msg.onStateChanged.listen((state) {
      if (state == SmsMessageState.Sending) {
        return Toast.show('Sending Alert...', context,
            duration: 1, backgroundColor: Colors.blue, backgroundRadius: 5);
      } else if (state == SmsMessageState.Sent) {
        return Toast.show('Alert Sent Successfully!', context,
            duration: 3, backgroundColor: Colors.green, backgroundRadius: 5);
      } else if (state == SmsMessageState.Fail) {
        return Toast.show(
            'Failure! Check your credits & Network Signals!', context,
            duration: 5, backgroundColor: Colors.red, backgroundRadius: 5);
      }
    });
    sender.sendSms(msg);
  }

  Future<void> sendAlertToContacts(String msg) async {
    List<String> recipients = [];
    LocationData myLocation;
    String error;
    Location location = new Location();
    var db =
        FirebaseDatabase.instance.reference().child(widget.user.phoneNumber);

    db.once().then((DataSnapshot snapshot) async {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) {
        recipients.add(values["phone"]);
      });
      try {
        myLocation = await location.getLocation();
        var currentLocation = myLocation;
        var coordinates =
            Coordinates(currentLocation.latitude, currentLocation.longitude);
        var addresses =
            await Geocoder.local.findAddressesFromCoordinates(coordinates);
        var first = addresses.first;

        String link =
            "http://maps.google.com/?q=${currentLocation.latitude},${currentLocation.longitude}";
        for (int i = 0; i < recipients.length; i++) {
          sendAlert(recipients[i], msg);
          sendAlert(recipients[i],
              "Address: ${first.addressLine}\n\nGoogle Maps: $link");
        }
      } on PlatformException catch (e) {
        if (e.code == 'PERMISSION_DENIED') {
          error = 'please grant permission';
          print(error);
        }
        if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
          error = 'permission denied- please enable it from app settings';
          print(error);
        }
      }
    });
  }

  Widget topText(double mediaQueryWidth, double mediaQueryHeight) {
    return Column(
      children: <Widget>[
        Text('Enter Incident Type &',
            style: TextStyle(
                fontFamily: 'Sogoe',
                fontSize: mediaQueryHeight * 0.03,
                color: Colors.white)),
        Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Text(
            'Press',
            style: TextStyle(
                fontFamily: 'Sogoe',
                fontSize: mediaQueryHeight * 0.03,
                color: Colors.white),
          ),
          SizedBox(width: mediaQueryWidth * 0.015),
          Icon(Icons.send, size: mediaQueryHeight * 0.035, color: Colors.white),
          SizedBox(width: mediaQueryWidth * 0.015),
          Text('button to inform',
              style: TextStyle(
                  fontFamily: 'Sogoe',
                  fontSize: mediaQueryHeight * 0.03,
                  color: Colors.white))
        ])
      ],
    );
  }

  Widget incidentTextField(double mediaQueryHeight) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.text,
      maxLength: 20,
      autofocus: false,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        counterStyle: TextStyle(color: Colors.white),
        hintText: 'e.g I need Help...',
        hintStyle: TextStyle(
            color: Colors.black38, fontSize: mediaQueryHeight * 0.018),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xff002262)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xff002262)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget contactTile(
      DataSnapshot res, double mediaQueryWidth, double mediaQueryHeight) {
    UploadContact uploadContact = UploadContact.fromSnapshot(res);
    return Container(
        padding: EdgeInsets.only(
            left: mediaQueryWidth * 0.01, right: mediaQueryWidth * 0.02),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(children: <Widget>[
          CircleAvatar(
              radius: mediaQueryHeight * 0.02,
              backgroundColor: Colors.white,
              child: Icon(Icons.person,
                  color: Colors.blue, size: mediaQueryHeight * 0.03)),
          SizedBox(width: mediaQueryWidth * 0.01),
          Text(uploadContact.name,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w700))
        ]));
  }
}
