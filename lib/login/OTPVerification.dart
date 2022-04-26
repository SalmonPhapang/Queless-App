import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/login/FinishRegistrationPage.dart';
import 'package:flutter_app/model/User.dart';
import 'package:flutter_app/service/NotificationService.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';
import 'package:progress_dialog/progress_dialog.dart';
class OTPVerification extends StatefulWidget {
  const OTPVerification({Key key,this.title,this.user}) : super(key: key);

  @override
  _OTPVerificationState createState() => _OTPVerificationState();

  final String title;
  final User user;
}

class _OTPVerificationState extends State<OTPVerification> {
  NotificationService notificationService =new NotificationService();
  int _otp;

  void sendOtp(){
    _otp = 1000 + Random().nextInt(9999 - 1000);
    notificationService.sendOTP(widget.user.cellNumber,_otp.toString());
  }
  @override
  void initState() {
    super.initState();
    sendOtp();
    print('otp : '+ _otp.toString());
  }
  @override
  Widget build(BuildContext context) {
    ProgressDialog progressDialog = new ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    progressDialog.style(
        message: 'Signing Up...',
        borderRadius: 10.0.sp,
        backgroundColor: Colors.white,
        progressWidget: SpinKitCubeGrid(color: Color(0xffff5722),size: 25.0.sp,),
        elevation: 10.0.sp,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0.sp,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 11.0.sp, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 18.0.sp, fontWeight: FontWeight.w600)
    );

    _verifyOtp(int verificationCode){
        bool matches = _otp == verificationCode;
        if(matches){
          Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: FinishRegistrationPage(title: "Secure Account",user: widget.user,)),);
        }else{
          Fluttertoast.showToast(msg: "Incorrect OTP entered",toastLength: Toast.LENGTH_LONG);
        }
    }
    final topAppBar = NewGradientAppBar(
      elevation: 0.1.sp,
      gradient: LinearGradient(colors: [Colors.cyan, Colors.indigo]),
      title: Text(widget.title),
    ); //AppBar
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: topAppBar,
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 35.0.sp,left: 10.0.sp),
                child: new Text(
                  'We sent you an OTP',
                  style: new TextStyle(
                    fontSize: 17.0.sp,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 10.0.sp,left: 10.0.sp),
                    child: new Text(
                      'On number',
                      style: new TextStyle(
                        fontSize: 12.5.sp,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0.sp,left: 5.0.sp),
                    child: new Text(
                      widget.user.cellNumber,
                      style: new TextStyle(
                        fontSize: 12.5.sp,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 50.0.sp),
                child: OtpTextField(
                  numberOfFields: 4,
                  borderColor: Colors.blue,
                  fieldWidth: 60.0.sp,
                  //set to true to show as box or false to show as dash
                  showFieldAsBox: true,
                  //runs when every textfield is filled
                  onSubmit: (String verificationCode){
                    _verifyOtp(int.parse(verificationCode));
                  }, // end onSubmit
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child:  Padding(
                      padding: EdgeInsets.all(15.0.sp),
                      child: new Text(
                        'Change number?',
                        style: new TextStyle(
                          fontSize: 12.5.sp,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      sendOtp();
                      Fluttertoast.showToast(msg: "Code resent successfully",toastLength: Toast.LENGTH_LONG);
                    },
                    highlightColor: Colors.orange,
                    child: Padding(
                      padding: EdgeInsets.all(15.0.sp),
                      child: new Text(
                        'Resend Code?',
                        style: new TextStyle(
                          fontSize: 12.0.sp,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Center(
                child:  Padding(
                padding: EdgeInsets.only(top: 10.0.sp,left: 10.0.sp),
                child: new Text(
                  'This helps us verify every user on our app',
                  style: new TextStyle(
                    fontSize: 12.0.sp,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),)
            ],
          ),
        ) ,);
  }
}
