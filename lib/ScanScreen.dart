import 'dart:async';
import 'dart:convert';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/ResultPage.dart';
import 'package:flutter_app/auth/Authentication.dart';
import 'package:flutter_app/model/CheckIn.dart';
import 'package:flutter_app/model/Feed.dart';
import 'package:flutter_app/service/CheckInService.dart';
import 'package:flutter_app/service/FeedService.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ScanScreen extends StatefulWidget {
  ScanScreen({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _ScanState createState() => new _ScanState();
}

class _ScanState extends State<ScanScreen> {
  String _barcode = "";
  Auth auth = new Auth();
  FeedService feedService = new FeedService();
  CheckInService checkInService = new CheckInService();
  ProgressDialog progressDialog;
  @override
  void initState() {
    super.initState();
  }

  Future scan() async {
     _barcode = await FlutterBarcodeScanner.scanBarcode("#ff6666","Cancel",true,ScanMode.QR);

     progressDialog.show();
     String userKey = await auth.getCurrentUser();
     String feedKey = _barcode;
     Feed feed = await feedService.fetchByKey(feedKey);

     List<CheckIn> checkinList = await checkInService.fetchByUser(userKey);
     CheckIn check;
     if(checkinList.isNotEmpty)
     {
        check =  checkinList.where((element) => element.feedKey.contains(feed.key)).first;
     }
     if(check == null){
       DateFormat format = new DateFormat("yyyy-MM-dd");
       CheckIn checkIn = new CheckIn.from(userKey: userKey,date: format.format(DateTime.now()),feedKey: feed.key);
       String checkInKey = await checkInService.save(checkIn);
       if(checkInKey!=null && checkInKey.isNotEmpty){
         checkIn.feed = feed;
         progressDialog.show();
         Navigator.push(context, MaterialPageRoute(builder: (context) => ResultPage(title: "Confirmation",checkIn: checkIn,)),
         );
       }
     }else{
       progressDialog.show();
       Fluttertoast.showToast(msg: "You have already checked In at "+feed.title+" on "+feed.date,toastLength: Toast.LENGTH_LONG);
     }
  }

  @override
  Widget build(BuildContext context) {
    final topAppBar = NewGradientAppBar(
      elevation: 0.1,
      gradient: LinearGradient(colors: [Colors.cyan,Colors.indigo]),
      title: Text(widget.title),
    );//AppBar
    progressDialog = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: true, showLogs: false);
    progressDialog.style(
        message: 'Submitting Order',
        borderRadius: 10.0.sp,
        backgroundColor: Colors.white,
        progressWidget: SpinKitCubeGrid(
          color: Color(0xffff5722),
          size: 25.0.sp,
        ),
        elevation: 10.0.sp,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 11.0.sp,
            fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18.0.sp,
            fontWeight: FontWeight.w600));
    return new Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: topAppBar,
      floatingActionButton: new FloatingActionButton(
      onPressed: scan,
        backgroundColor: Colors.red,
        //if you set mini to true then it will make your floating button small
        mini: false,
        child: new Icon(Icons.camera_enhance),
      ),
      body: Container(
        child:Center(
          child: Image.asset('assets/images/turnupQR.png',width: 400.0,height: 300.0,alignment: Alignment.center,),
        )
      ),
    );
  }

}