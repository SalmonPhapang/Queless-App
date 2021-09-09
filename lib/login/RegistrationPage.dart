import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/adddress/AddressSearchPage.dart';
import 'package:flutter_app/auth/Authentication.dart';
import 'package:flutter_app/enums/Topics.dart';
import 'package:flutter_app/model/Credentials.dart';
import 'package:flutter_app/model/User.dart';
import 'package:flutter_app/service/AuthenticationService.dart';
import 'package:flutter_app/service/UserService.dart';
import 'package:flutter_app/utils/TopWaveClipper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AddressAddPage.dart';

class RegistrationPage extends StatefulWidget {
  RegistrationPage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  TextStyle style = TextStyle(fontFamily: 'san-serif', fontSize: 15.0.sp);
  Auth auth = new Auth();
  UserService userService = new UserService();
  AuthenticationService authenticationService = new AuthenticationService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  String _name;
  String _email;
  String _mobile;
  String _lastName;
  String _password;
  String _confirmPassword;
  TextEditingController password = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();
  @override
  Widget build(BuildContext context) {

    String validateName(String value) {
      if (value.length < 3)
        return 'Name must be more than 2 charater';
      else
        return null;
    }

    String validateMobile(String value) {
      if (value.length != 10)
        return 'Mobile Number must be of 10 digit';
      else
        return null;
    }

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
    String validateEmail(String value) {
      Pattern pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = new RegExp(pattern);
      if (!regex.hasMatch(value))
        return 'Enter Valid Email';
      else
        return null;
    }
    final nameField = TextFormField(
      obscureText: false,
      style: style,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      validator: validateName,
      onSaved: (String value) {
        _name = value;
      },
      decoration: InputDecoration(
          hintText: "First Name",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
    );//nameField
    final lastNameField = TextFormField(
      obscureText: false,
      style: style,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      validator: validateName,
      onSaved: (String value) {
        _lastName = value;
      },
      decoration: InputDecoration(
          hintText: "Last Name",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
    );//nameField
    final cellField = TextFormField(
      obscureText: false,
      style: style,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      validator: validateMobile,
      onSaved: (String value) {
        _mobile = value;
      },
      decoration: InputDecoration(
          hintText: "Cell Number",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
    );//nameField
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
          hintText: "Email",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
    );//emailField
    final passwordField = TextFormField(
      obscureText: true,
      style: style,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      validator: validatePassword ,
      onSaved: (String value) {
        _password = value;
      },
      decoration: InputDecoration(
          hintText: "Password",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
    );// passwordField
    final confirmPasswordField = TextFormField(
      obscureText: true,
      style: style,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      validator: validateConfirmPassword ,
      onSaved: (String value) {
        _password = value;
      },
      decoration: InputDecoration(
          hintText: "Confrim Password",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
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
      String token = await FirebaseMessaging.instance.getToken();
      User user = new User.from(name: _name,lastName: _lastName,email: _email,cellNumber: _mobile,status: true,emailVerified: false,fcmToken: token);
      String key  = await userService.save(user);

      Credentials credentials = Credentials(userName: user.email,password: _password,userKey: key);
      String credentialsKey = await authenticationService.save(credentials);

      if(credentialsKey != null && credentialsKey.isNotEmpty){
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userKey', key);
        FirebaseMessaging.instance.subscribeToTopic(Topics.PROMOTIONS);
        FirebaseMessaging.instance.subscribeToTopic(Topics.MARKETING);
        progressDialog.hide();
        Navigator.push(context, MaterialPageRoute(builder: (context) => AddressSearchPage(title: "Find Address",user: user,)),);
      }else{
        Fluttertoast.showToast(msg: "UserName with email already exists, Please go to login "+_email,toastLength: Toast.LENGTH_LONG);
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

    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 245, 245, 1),
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
                      height: ScreenUtil().setHeight(MediaQuery.of(context).size.height / 2.9.sp),
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
                  )
                ],
              ),
              new Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(5.sp),
                        child:nameField,
                      ),
                      Padding(
                        padding: EdgeInsets.all(5.sp),
                        child:lastNameField,
                      ),
                      Padding(
                        padding: EdgeInsets.all(5.sp),
                        child:cellField,
                      ),
                      Padding(
                        padding: EdgeInsets.all(5.sp),
                        child:emailField,
                      ),
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
              SizedBox(height: 5.0.sp,),
              Container(
                width: MediaQuery.of(context).size.width.sp,
                margin: EdgeInsets.only(top:5.0.sp,left: 5.0.sp,right: 5.0.sp),
                height: 50.0.sp,
                child:  FlatButton(
                  onPressed: (){
                    _validateForm();
                  },
                  child: new Text(
                    "Sign Up",
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
              Padding(
                padding: EdgeInsets.only(top:ScreenUtil().setHeight(20.sp)),
                child:  InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: new Center(child:  Text.rich(
                        TextSpan(
                            style: new TextStyle(
                                fontSize: 18.sp,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold
                            ),
                            text: "Already have account? ",
                            children: <TextSpan>[
                              TextSpan(
                                text: "Login",
                                style: new TextStyle(
                                    fontSize: 18.sp,
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
      ),

    );

  }

}