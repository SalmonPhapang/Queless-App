import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/ResultPage.dart';
import 'package:flutter_app/auth/Authentication.dart';
import 'package:flutter_app/model/CheckIn.dart';
import 'package:flutter_app/model/Constants.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanScreen extends StatefulWidget {
  ScanScreen({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _ScanState createState() => new _ScanState();
}

class _ScanState extends State<ScanScreen> {
  String _barcode = "";
  Auth auth = new Auth();
  DatabaseReference _checkInReference;
  @override
  void initState() {
    super.initState();
     auth.getCurrentUser().then((user) {
      setState(() {
      _checkInReference = FirebaseDatabase.instance.reference().child("Users");
      });
    });
  }
  Future scan() async {
     _barcode = await FlutterBarcodeScanner.scanBarcode("#ff6666","Cancel",true,ScanMode.QR);
     User user = await auth.getCurrentUser();
     setState(() {
       {
         Map<String, dynamic>  parsedJson = json.decode(_barcode);
         CheckIn checkIn = new CheckIn(parsedJson['imageUrl'], parsedJson['name'], parsedJson['shots'], parsedJson['date']);
          _checkInReference.child(user.uid).child("Checkin").once().then((DataSnapshot snapshot){
            var DATA = snapshot.value;
            bool exists = false;
            if(DATA != null) {
              var KEYS = snapshot.value.keys;
              for (var individualKey in KEYS) {
                CheckIn existingCheckIn = new CheckIn(
                    DATA[individualKey]['imageUrl'],
                    DATA[individualKey]['name'], DATA[individualKey]['shots'],
                    DATA[individualKey]['date']);
                if (checkIn.name == existingCheckIn.name &&
                    checkIn.date == existingCheckIn.date) {
                  exists = true;
                  break;
                }
              }
            }
            if(!exists){
              FirebaseDatabase.instance.reference().child("Users").child(user.uid).child("Checkin").push().set(parsedJson).whenComplete((){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ResultPage(title: "Congrates",checkIn: checkIn,)),
                );
              });
            }else{
                Fluttertoast.showToast(msg: "You have already checked In at "+checkIn.name+" on "+checkIn.date,toastLength: Toast.LENGTH_LONG);
            }

          });


        }
     });
  }

  @override
  Widget build(BuildContext context) {
    final topAppBar = NewGradientAppBar(
      elevation: 0.1,
      gradient: LinearGradient(colors: [Colors.cyan,Colors.indigo]),
      title: Text(widget.title),
    );//AppBar

    return new Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      appBar: topAppBar,
      floatingActionButton: new FloatingActionButton(
      onPressed: scan,
        backgroundColor: Colors.red,
        //if you set mini to true then it will make your floating button small
        mini: false,
        child: new Icon(Icons.camera_enhance),
      ),
      body: new Container(
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/turnupQR.png',width: 400.0,height: 300.0,alignment: Alignment.center,)
          ],
        )
      ),
    );
  }

}