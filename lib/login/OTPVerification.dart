import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/adddress/AddressSearchPage.dart';
import 'package:flutter_app/enums/Topics.dart';
import 'package:flutter_app/model/Credentials.dart';
import 'package:flutter_app/model/User.dart';
import 'package:flutter_app/service/AuthenticationService.dart';
import 'package:flutter_app/service/UserService.dart';
import 'package:flutter_app/utils/TopWaveClipper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_otp/flutter_otp.dart';
import 'package:page_transition/page_transition.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
class OTPVerification extends StatefulWidget {
  const OTPVerification({Key key,this.title,this.user}) : super(key: key);

  @override
  _OTPVerificationState createState() => _OTPVerificationState();

  final String title;
  final User user;
}

class _OTPVerificationState extends State<OTPVerification> {
  FlutterOtp otp = FlutterOtp();
  UserService userService = new UserService();
  AuthenticationService authenticationService = new AuthenticationService();
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
    Future<void> _handleSignUp() async{
      progressDialog.show();
      String key  = await userService.save(widget.user);
      if(key != null && key.isNotEmpty){
        Credentials credentials = Credentials(userName: widget.user.email,password: widget.user.password,userKey: key);
        await authenticationService.save(credentials);

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userKey', key);
        FirebaseMessaging.instance.subscribeToTopic(Topics.PROMOTIONS);
        FirebaseMessaging.instance.subscribeToTopic(Topics.MARKETING);
        progressDialog.hide();
        Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: AddressSearchPage(title: "Find Address",user: widget.user,)),);
      }else{
        progressDialog.hide();
        Fluttertoast.showToast(msg: "UserName with email already exists",toastLength: Toast.LENGTH_LONG);
      }
    }
    final topAppBar = NewGradientAppBar(
      elevation: 0.1.sp,
      gradient: LinearGradient(colors: [Colors.cyan, Colors.indigo]),
      title: Text("Delivery or Collection"),
    ); //AppBar
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: topAppBar,
        body:Center(
          child: Column(
            children: <Widget>[
              OTPTextField(
                length: 5,
                width: MediaQuery.of(context).size.width,
                fieldWidth: 80,
                style: TextStyle(
                    fontSize: 17
                ),
                textFieldAlignment: MainAxisAlignment.spaceAround,
                fieldStyle: FieldStyle.underline,
                onCompleted: (pin) {
                  print("Completed: " + pin);
                 bool matches = otp.resultChecker(int.parse(pin));
                 if(matches){
                   _handleSignUp();
                 }else{
                   Fluttertoast.showToast(msg: "Incorrect OTP entered",toastLength: Toast.LENGTH_LONG);
                 }
                },
              ),
              new InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: new Container(
                    height: 50.0.sp,
                    width: 150.sp,
                    margin: EdgeInsets.only(
                        top: 10.0.sp,
                        right: 10.0.sp,
                        bottom: 10.0.sp),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(5.0.sp)),
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.topRight,
                            colors: TopWaveClipper
                                .blueGradients)),
                    child: Center(
                      child: new Text(
                        'Change Number',
                        softWrap: true,
                        style: new TextStyle(
                          fontSize: 15.0.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    )),
              ),
            ],
          ),
        ));
  }
}
