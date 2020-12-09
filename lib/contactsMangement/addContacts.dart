import 'dart:io';
import 'package:com/contactsMangement/phoneBook.dart';
import 'package:com/locationOnMap.dart';
import 'package:com/model/uploadContact.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:sms_maintained/sms.dart';
import 'package:toast/toast.dart';
import 'package:com/Animation/bottomAnimation.dart';

class AddContacts extends StatefulWidget {
  final FirebaseUser user;
  AddContacts({this.user});

  @override
  _AddContactsState createState() => _AddContactsState();
}

class _AddContactsState extends State<AddContacts>{
  bool contactAvail = false;

  @override
  void initState() {
    super.initState();
    initialContacts();
  }
  

  callBack(boolVar) {
    setState(() {
      contactAvail = boolVar;
    });
  }

  initialContacts() {
    var db =
        FirebaseDatabase.instance.reference().child(widget.user.phoneNumber);
    db.once().then((DataSnapshot snapshot) {
      if (snapshot.value == null) {
        setState(() {
          contactAvail = false;
        });
      } else {
        setState(() {
          contactAvail = true;
        });
      }
    });
  }

  _getInitialLocation() async {
    var db =
        FirebaseDatabase.instance.reference().child(widget.user.phoneNumber);

    LocationData myLocation;
    String error;
    Location location = new Location();
    try {
      myLocation = await location.getLocation();
      var currentLocation = myLocation;
      setState(() {
        var initLocLat = currentLocation.latitude;
        var initLocLong = currentLocation.longitude;
        db.once().then((DataSnapshot snapshot) {
          if (snapshot.value == null) {
            return Toast.show('No Contacts Found!', context,
                backgroundColor: Colors.red,
                backgroundRadius: 5,
                duration: 3,
                gravity: Toast.CENTER);
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LocationOnMap(
                          user: widget.user,
                          initLat: initLocLat,
                          initLong: initLocLong,
                        )));
          }
        });
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Please grant permission';
        print(error);
      }
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'Permission denied- please enable it from app settings';
        print(error);
      }
      myLocation = null;
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: new Text(
              "Exit Application",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: new Text("Are You Sure?"),
            actions: <Widget>[
              FlatButton(
                shape: StadiumBorder(),
                color: Colors.white,
                child: new Text(
                  "No",
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                shape: StadiumBorder(),
                color: Colors.white,
                child: new Text(
                  "Yes",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  exit(0);
                },
              ),
            ],
          ),
        )) ??
        false;
  }

  void sendAlert(String number, String msgText) {
    SmsMessage msg = new SmsMessage(number, msgText);
    final SmsSender sender = new SmsSender();
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

  _sendingSMSUsingLogo() async {
    List<String> recipients = [];
    var db =
        FirebaseDatabase.instance.reference().child(widget.user.phoneNumber);

    LocationData myLocation;
    String error;
    Location location = new Location();
    try {
      myLocation = await location.getLocation();
      var currentLocation = myLocation;
      setState(() {
        db.once().then((DataSnapshot snapshot) async {
          Map<dynamic, dynamic> values = snapshot.value;

          if (snapshot.value == null) {
            return Toast.show('No Contacts Found!', context,
                backgroundColor: Colors.red,
                backgroundRadius: 5,
                duration: 3,
                gravity: Toast.CENTER);
          } else {
            values.forEach((key, values) {
              recipients.add(values["phone"]);
            });

            var coordinates = Coordinates(
                currentLocation.latitude, currentLocation.longitude);
            var addresses =
                await Geocoder.local.findAddressesFromCoordinates(coordinates);
            var first = addresses.first;
            String link =
                "http://maps.google.com/?q=${currentLocation.latitude},${currentLocation.longitude}";
            for (int i = 0; i < recipients.length; i++) {
              sendAlert(recipients[i],
                  "It's an Emergency!\n${first.addressLine}\n$link");
            }
          }
        });
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Please grant permission';
        print('Error due to Denied: $error');
      }
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'Permission denied- please enable it from app settings';
        print("Error due to not Asking: $error");
      }
      myLocation = null;
    }
  }

  final FirebaseDatabase database = new FirebaseDatabase();

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    DatabaseReference contactRef =
        database.reference().child(widget.user.phoneNumber);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          body: Container(
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
              Color(0xff002262)
            ])),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: _sendingSMSUsingLogo,
                child:
                    Image.asset('assets/alertlogo.png', height: height * 0.17),
              ),
              SizedBox(height: height * 0.02),
              Text(
                "Add Contacts to be Informed",
                style: TextStyle(
                    fontFamily: 'Sogoe',
                    color: Colors.white,
                    fontSize: height * 0.022),
              ),
              SizedBox(height: height * 0.03),
              contactAvail
                  ? Container(
                      width: width * 0.7,
                      height: height * 0.26,
                      margin: EdgeInsets.symmetric(horizontal: width * 0.03),
                      child: FirebaseAnimatedList(
                          scrollDirection: Axis.vertical,
                          query: contactRef,
                          itemBuilder: (BuildContext context,
                              DataSnapshot snapshot,
                              Animation<double> animation,
                              int index) {
                            return WidgetAnimator(
                                contactTile(snapshot, index, contactRef));
                          }),
                    )
                  : Text('Add Contact(s) from Phone book.',
                      style:
                          TextStyle(fontFamily: 'Sogoe', color: Colors.green)),
              SizedBox(height: height * 0.02),
              contactAvail
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.delete,
                            color: Colors.red, size: height * 0.025),
                        SizedBox(width: width * 0.01),
                        Text(
                          'Tap to Remove Contact',
                          style:
                              TextStyle(fontFamily: 'Sogoe', color: Colors.red),
                        )
                      ],
                    )
                  : Container(),
              SizedBox(height: height * 0.02),
              addContactBtn(context),
              SizedBox(height: height * 0.02),
              sendAlertBtn(context, _getInitialLocation),
              SizedBox(height: height * 0.02),
              contactAvail
                  ? Text(
                      'In Case of severe injury tap the Alert Logo\nto send default SMS!',
                      style:
                          TextStyle(fontFamily: 'Sogoe', color: Colors.yellow),
                      textAlign: TextAlign.center)
                  : Container()
            ],
          ),
        ),
      )),
    );
  }

  Widget contactTile(DataSnapshot res, int index, DatabaseReference reference) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    index++;
    UploadContact uploadContact = UploadContact.fromSnapshot(res);
    return Container(
      padding: EdgeInsets.symmetric(vertical: height * 0.005),
      width: width,
      child: FlatButton(
        padding: EdgeInsets.symmetric(
            horizontal: width * 0.01, vertical: height * 0.005),
        shape: StadiumBorder(),
        color: Colors.white.withOpacity(0.5),
        onPressed: () {
          reference.child(uploadContact.key).remove();
          Toast.show("Contact Removed!", context,
              backgroundColor: Colors.red, duration: 3, backgroundRadius: 5);
          var db = FirebaseDatabase.instance
              .reference()
              .child(widget.user.phoneNumber);
          db.once().then((DataSnapshot snapshot) {
            if (snapshot.value == null) {
              setState(() {
                contactAvail = false;
              });
            }
          });
        },
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: height * 0.03,
              backgroundColor: Colors.white,
              child:
                  Icon(Icons.person, color: Colors.blue, size: height * 0.045),
            ),
            SizedBox(width: width * 0.025),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  uploadContact.name,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: height * 0.01),
                Text("Contact " + index.toString(),
                    style: TextStyle(color: Colors.white54)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget addContactBtn(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.80,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white54),
          borderRadius: BorderRadius.circular(32)),
      child: FlatButton(
        splashColor: Color(0xff0D2C5F),
        padding: EdgeInsets.all(10.0),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PhoneBook(
                      user: widget.user,
                      contactAvailable: contactAvail,
                      callback: callBack)));
        },
        shape: StadiumBorder(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            WidgetAnimator(
              Icon(Icons.contacts,
                  color: Colors.white,
                  size: MediaQuery.of(context).size.height * .03),
            ),
            Text('Add From Phone Book',
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * .025,
                    fontWeight: FontWeight.w700,
                    color: Colors.white))
          ],
        ),
      ),
    );
  }

  Widget sendAlertBtn(BuildContext context, Function ftn) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.80,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white54),
          borderRadius: BorderRadius.circular(32)),
      child: FlatButton(
        splashColor: Color(0xff0D2C5F),
        onPressed: () {
          ftn();
        },
        shape: StadiumBorder(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            WidgetAnimator(
              Icon(Icons.warning,
                  color: Colors.white,
                  size: MediaQuery.of(context).size.height * .03),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            Text('Send Alert!',
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * .025,
                    fontWeight: FontWeight.w700,
                    color: Colors.white))
          ],
        ),
      ),
    );
  }
}
