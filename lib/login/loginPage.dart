import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/HomePage.dart';
import 'package:flutter_app/auth/Authentication.dart';
import 'package:flutter_app/login/RegistrationPage.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/model/Credentials.dart';
import 'package:flutter_app/model/User.dart';
import 'package:flutter_app/service/AuthenticationService.dart';
import 'package:flutter_app/service/UserService.dart';
import 'package:flutter_app/utils/BottomWaveClipper.dart';
import 'package:flutter_app/utils/TopWaveClipper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math';
class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextStyle style = TextStyle(fontFamily: 'san-serif', fontSize: 20.0.sp);
  UserService userService = new UserService();
  AuthenticationService authenticationService = new AuthenticationService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  String _email;
  String _password;

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    String validatePassword(String value){
      String  pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
      RegExp regExp = new RegExp(pattern);
      if (!regExp.hasMatch(value))
        return 'Password too weak';
      else
        return null;
    }
    String validateEmail(String value) {
      Pattern pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = new RegExp(pattern);
      if (!regex.hasMatch(value))
        return 'Enter Valid Email';
      else
        return null;
    }

    final emailField = TextFormField(
      obscureText: false,
      style: style,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: validateEmail,
      onSaved: (String value) {
        _email = value;
      },
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Email",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
    );//emailField
    final passwordField = TextFormField(
      obscureText: true,
      style: style,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      validator: validatePassword ,
      onSaved: (String value) {
        _password = value;
      },
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
    );// passwordField
    ProgressDialog progressDialog = new ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: true, showLogs: false);
    progressDialog.style(
        message: 'Signing In...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: SpinKitCubeGrid(color: Color(0xffff5722),size: 25.0,),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 11.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.w600)
    );
    Future<void> _handleSignIn() async{
      progressDialog.show();
      Credentials credentials = Credentials(userName: _email,password: _password);
      String userKey = await authenticationService.signIn(credentials);

      if(userKey != null && userKey.isNotEmpty) {
        String token = await FirebaseMessaging.instance.getToken();
        User user = await userService.fetchByKey(userKey);
        user.fcmToken = token;

        String updatedKey = await userService.update(user);

        if(updatedKey != null && updatedKey.isNotEmpty){
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('userKey', userKey);

          progressDialog.hide();
          Fluttertoast.showToast(msg: "Welcome back "+_email,toastLength: Toast.LENGTH_LONG);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavBar()),);
        }
      }else{
        progressDialog.hide();
        Fluttertoast.showToast(msg: 'invalid Credentials entered, Please enter correct userName and password',toastLength: Toast.LENGTH_LONG);
        progressDialog.hide();
      }
    }
    void _validateForm() {
      if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
        _formKey.currentState.save();
        _handleSignIn();
      } else {
//    If all data are not valid then start auto validation.
        setState(() {
          _autoValidate = true;
        });
      }
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child:  new Column(
            children: <Widget>[
              new Stack(
                children: <Widget>[
                  new ClipPath(
                    clipper: TopWaveClipper(),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: TopWaveClipper.orangeGradients,
                            begin: Alignment.topLeft,
                            end: Alignment.center),
                      ),
                      height: MediaQuery.of(context).size.height.sp / 2.7.sp,
                    ),
                  ),//ClipPath
                  new Center(
                    child: Container(
                      width: 100.0.sp,
                      height: 100.0.sp,
                      margin: EdgeInsets.only(top: 120.sp),
                      decoration: new BoxDecoration(
                        image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage("assets/logo.png"),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              new Form(
                key: _formKey,
                autovalidateMode:AutovalidateMode.disabled ,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10),
                      child:emailField,
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: passwordField,
                    ),
                  ],
                ),
              ),
              Container(
                width: 200.sp,
                child: FlatButton(
                  onPressed: (){
                    _validateForm();
                  },
                  child: new Text(
                    "Login",
                    style: new TextStyle(
                        fontSize: 18.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.center,
                  ),
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.blue)
                  ),
                ),
              ),

              SizedBox(height: 10.0.sp,),
              // new Column(
              //   children: <Widget>[
              //     SizedBox(height: 10.sp,),
              //     new Center(child: new Text(
              //       "Or choose a login method",
              //       style: new TextStyle(
              //           fontSize: 15.sp,
              //           color: Colors.black54,
              //           fontWeight: FontWeight.bold
              //       ),
              //       textAlign: TextAlign.center,
              //     )),
              //     SizedBox(height: 10.sp,),
              //     new Center(child:GoogleSignInButton(onPressed: _handleSignIn,borderRadius:30.0,text: "Google ",)),
              //     SizedBox(height: 10.sp,),
              //   ],
              // ),
              Padding(
                padding: EdgeInsets.only(top:20.sp),
                child:  InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationPage(title: "Register",)),);
                    },
                    child: new Center(child:  Text.rich(
                        TextSpan(
                            style: new TextStyle(
                                fontSize: 15.sp,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold
                            ),
                            text: "Don't have account? ",
                            children: <TextSpan>[
                              TextSpan(
                                text: "Sign Up",
                                style: new TextStyle(
                                    fontSize: 15.sp,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold
                                ),
                              )
                            ]
                        )
                    ) ,

                    )
                ),
              ),

//          Transform(
//            transform: Matrix4.rotationX(pi),
//            alignment: Alignment.bottomCenter,
//              child: new ClipPath(
//                clipper: BottomWaveClipper(),
//                child: Container(
//                  decoration: BoxDecoration(
//                    gradient: LinearGradient(
//                        colors: TopWaveClipper.orangeGradients,
//                        begin: Alignment.topLeft,
//                        end: Alignment.center),
//                  ),
//                  height: ScreenUtil().setHeight(60),
//                  width:MediaQuery.of(context).size.width ,
//                ),
//              ),//ClipPath
//            ),
            ]
        ),
      )
    );
  }
  static List<Color> signInGradients = [
    Color(0xFF0EDED2),
    Color(0xFF03A0FE),
  ];

  static List<Color> signUpGradients = [
    Color(0xFFFF9945),
    Color(0xFFFc6076),
  ];

}