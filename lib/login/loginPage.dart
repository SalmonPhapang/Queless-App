import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/HomePage.dart';
import 'package:flutter_app/auth/Authentication.dart';
import 'package:flutter_app/login/RegistrationPage.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/utils/BottomWaveClipper.dart';
import 'package:flutter_app/utils/TopWaveClipper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'dart:math';
class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  Auth auth = new Auth();
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
      validator: validateEmail,
      onSaved: (String value) {
        _email = value;
      },
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Email",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );//emailField
    final passwordField = TextFormField(
      obscureText: true,
      style: style,
      keyboardType: TextInputType.text,
      validator: validatePassword ,
      onSaved: (String value) {
        _password = value;
      },
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
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
       auth.signIn(_email, _password).then((currentUser){
       if(currentUser != null) {
         progressDialog.hide();
         Fluttertoast.showToast(msg: "Welcome back "+currentUser.email,toastLength: Toast.LENGTH_LONG);
         Navigator.pushReplacement(
         context, MaterialPageRoute(builder: (context) => BottomNavBar()),);
    }
      }).catchError((onError){
        Fluttertoast.showToast(msg: onError.message,toastLength: Toast.LENGTH_LONG);
        progressDialog.hide();
      });

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
                      height: ScreenUtil().setHeight(MediaQuery.of(context).size.height / 2.7),
                    ),
                  ),//ClipPath
                  new Center(
                    child:new Container(
                      width: ScreenUtil().setWidth(240.0),
                      height: ScreenUtil().setHeight(100.0),
                      margin: EdgeInsets.only(top: 200.0 ),
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: new AssetImage("assets/ic_launcher_2.png")
                        ),
                      ),
                    ) ,
                  ),
                ],
              ),

              new Form(
                key: _formKey,
                autovalidate: _autoValidate,
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
                width: ScreenUtil().setWidth(250.0),
                child: FlatButton(
                  onPressed: (){
                    _validateForm();
                  },
                  child: new Text(
                    "Login",
                    style: new TextStyle(
                        fontSize: ScreenUtil().setSp(25.0),
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

              SizedBox(height: 10.0,),
              new Column(
                children: <Widget>[
                  SizedBox(height: ScreenUtil().setHeight(10.0),),
                  new Center(child: new Text(
                    "Or choose a login method",
                    style: new TextStyle(
                        fontSize: ScreenUtil().setSp(20.0),
                        color: Colors.black54,
                        fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.center,
                  )),
                  SizedBox(height: ScreenUtil().setHeight(10.0),),
                  new Center(child:GoogleSignInButton(onPressed: _handleSignIn,borderRadius:30.0,text: "Google ",)),
                  SizedBox(height: ScreenUtil().setHeight(10.0),),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top:ScreenUtil().setHeight(60)),
                child:  InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationPage(title: "Register",)),);
                    },
                    child: new Center(child:  Text.rich(
                        TextSpan(
                            style: new TextStyle(
                                fontSize: ScreenUtil().setSp(20.0),
                                color: Colors.black54,
                                fontWeight: FontWeight.bold
                            ),
                            text: "Don't have account? ",
                            children: <TextSpan>[
                              TextSpan(
                                text: "Sign Up",
                                style: new TextStyle(
                                    fontSize: ScreenUtil().setSp(20.0),
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