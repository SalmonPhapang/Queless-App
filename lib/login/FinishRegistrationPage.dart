import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/adddress/AddressSearchPage.dart';
import 'package:flutter_app/auth/Authentication.dart';
import 'package:flutter_app/enums/Topics.dart';
import 'package:flutter_app/login/OTPVerification.dart';
import 'package:flutter_app/model/Credentials.dart';
import 'package:flutter_app/model/User.dart';
import 'package:flutter_app/service/AuthenticationService.dart';
import 'package:flutter_app/service/UserService.dart';
import 'package:flutter_app/utils/TopWaveClipper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AddressAddPage.dart';

class FinishRegistrationPage extends StatefulWidget {
  FinishRegistrationPage({Key key, this.title,this.user}) : super(key: key);

  final String title;
  final User user;
  @override
  _FinishRegistrationPageState createState() => _FinishRegistrationPageState();
}

class _FinishRegistrationPageState extends State<FinishRegistrationPage> {
  TextStyle style = TextStyle(fontFamily: 'san-serif', fontSize: 15.0.sp);
  Auth auth = new Auth();
  UserService userService = new UserService();
  AuthenticationService authenticationService = new AuthenticationService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _passwordVisible = false;
  bool _confirmVisible = false;
  String _password;
  String _confirmPassword;
  TextEditingController password = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();
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
    String validateConfirmPassword(String value){
      if (password.text != confirmpassword.text) {
        return "Password does not match";
      }else{
        return null;
      }
    }
    final passwordField = TextFormField(
      obscureText: !_passwordVisible,
      style: style,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      validator: validatePassword ,
      onSaved: (String value) {
        _password = value;
      },
      decoration: InputDecoration(
          hintText: "Password",
          suffixIcon: IconButton(
            icon: Icon(
              // Based on passwordVisible state choose the icon
              _passwordVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: Theme.of(context).primaryColorDark,
            ), onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
    );// passwordField
    final confirmPasswordField = TextFormField(
      obscureText: !_confirmVisible,
      style: style,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      validator: validateConfirmPassword ,
      onSaved: (String value) {
        _password = value;
      },
      decoration: InputDecoration(
          hintText: "Confirm Password",
          suffixIcon: IconButton(
              icon: Icon(
                _confirmVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: Theme.of(context).primaryColorDark,
              ), onPressed: () {
            setState(() {
              _confirmVisible = !_confirmVisible;
            });
          },),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
    );// passwordField
    ProgressDialog progressDialog = new ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: true, showLogs: false);
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

      Credentials credentials = Credentials(userName: widget.user.email,password: _password,userKey: key);
      String credentialsKey = await authenticationService.save(credentials);

      if(credentialsKey != null && credentialsKey.isNotEmpty){
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userKey', key);
        FirebaseMessaging.instance.subscribeToTopic(Topics.PROMOTIONS);
        FirebaseMessaging.instance.subscribeToTopic(Topics.MARKETING);
        progressDialog.hide();
        Navigator.push(context, MaterialPageRoute(builder: (context) => AddressSearchPage(title: "Find Address",user: widget.user,)),);
      }else{
        Fluttertoast.showToast(msg: "UserName with email already exists, Please go to login "+widget.user.email,toastLength: Toast.LENGTH_LONG);
      }
    }
    void _validateForm() {
      if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
        _formKey.currentState.save();
        _handleSignUp();
      } else {
//    If all data are not valid then start auto validation.
        setState(() {
          _autoValidate = true;
        });
      }
    }
    final topAppBar = NewGradientAppBar(
      elevation: 0.1.sp,
      gradient: LinearGradient(colors: [Colors.cyan, Colors.indigo]),
      title: Text(widget.title),
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: topAppBar,
      body: SingleChildScrollView(
        child:  new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
              padding: EdgeInsets.only(top: 35.0.sp,left: 10.0.sp),
              child: new Text(
                'Lets Secure your account',
                style: new TextStyle(
                  fontSize: 17.0.sp,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
              Padding(
                padding: EdgeInsets.only(top: 10.0.sp,left: 10.0.sp,bottom: 20.0.sp),
                child: new Text(
                  'Enter a secure password, you wont forget',
                  style: new TextStyle(
                    fontSize: 12.0.sp,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              new Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(5.sp),
                        child: passwordField,
                      ),
                      Padding(
                        padding: EdgeInsets.all(5.sp),
                        child: confirmPasswordField,
                      ),
                    ],
                  )),
              Container(
                width: MediaQuery.of(context).size.width.sp,
                margin: EdgeInsets.only(top:5.0.sp,left: 5.0.sp,right: 5.0.sp),
                height: 50.0.sp,
                child:  FlatButton(
                  onPressed: (){
                    _validateForm();
                  },
                  child: new Text(
                    "Finish",
                    style: new TextStyle(
                        fontSize: 17.0.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.center,
                  ),
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0.sp),
                      side: BorderSide(color: Colors.blue)
                  ),
                ),
              ),
            ]
        ),
      ),

    );

  }

}