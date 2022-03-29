import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/adddress/AddressSearchPage.dart';
import 'package:flutter_app/auth/Authentication.dart';
import 'package:flutter_app/enums/Topics.dart';
import 'package:flutter_app/model/Credentials.dart';
import 'package:flutter_app/model/User.dart';
import 'package:flutter_app/service/AuthenticationService.dart';
import 'package:flutter_app/service/UserService.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:page_transition/page_transition.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'OTPVerification.dart';

class RegistrationStepPage extends StatefulWidget {
  RegistrationStepPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RegistrationStepPageState createState() => _RegistrationStepPageState();
}

class _RegistrationStepPageState extends State<RegistrationStepPage> {
  int _currentStep = 0;
  TextStyle style = TextStyle(fontFamily: 'san-serif', fontSize: 15.0.sp);
  Auth auth = new Auth();
  UserService userService = new UserService();
  AuthenticationService authenticationService = new AuthenticationService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _terms = false;
  String _name;
  String _email;
  String _mobile;
  String _lastName;
  String _password;
  String _confirmPassword;
  TextEditingController password = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();
  DateTime currentDate = DateTime.now();
  DateTime pickedDate = DateTime.now();
  TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    _dateController.text = DateFormat.yMd().format(currentDate);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String validateName(String value) {
      if (value.length < 3)
        return 'Name must be more than 2 charater';
      else
        return null;
    }

    String validateLastName(String value) {
      if (value.length < 3)
        return 'Last Name must be more than 2 charater';
      else
        return null;
    }

    String validateMobile(String value) {
      if (value.length != 10)
        return 'Mobile Number must be of 10 digit';
      else
        return null;
    }

    String validateDateOfBirth(String value) {
      if (currentDate.year - pickedDate.year < 18)
        return 'You have to be 18 years or older to use the app';
      else
        return null;
    }

    String validatePassword(String value) {
      String pattern =
          r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
      RegExp regExp = new RegExp(pattern);
      if (!regExp.hasMatch(value))
        return 'Password too weak';
      else
        return null;
    }

    String validateConfirmPassword(String value) {
      if (password.text != confirmpassword.text) {
        return "Password does not match";
      } else {
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
          labelText: "First Name",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
    ); //nameField
    final lastNameField = TextFormField(
      obscureText: false,
      style: style,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      validator: validateLastName,
      onSaved: (String value) {
        _lastName = value;
      },
      decoration: InputDecoration(
          labelText: "Last Name",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
    ); //nameField
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
          labelText: "Mobile Number",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
    ); //nameField
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
          labelText: "Email",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
    ); //emailField
    final passwordField = TextFormField(
      obscureText: true,
      controller: password,
      style: style,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      validator: validatePassword,
      onSaved: (String value) {
        _password = value;
      },
      decoration: InputDecoration(
          labelText: "Password",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
    ); // passwordField
    final confirmPasswordField = TextFormField(
      obscureText: true,
      controller: confirmpassword,
      style: style,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      validator: validateConfirmPassword,
      onSaved: (String value) {
        _password = value;
      },
      decoration: InputDecoration(
          labelText: "Confirm Password",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
    ); // passwordField
    ProgressDialog progressDialog = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    progressDialog.style(
        message: 'Signing Up...',
        borderRadius: 10.0.sp,
        backgroundColor: Colors.white,
        progressWidget: SpinKitCubeGrid(
          color: Color(0xffff5722),
          size: 25.0.sp,
        ),
        elevation: 10.0.sp,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0.sp,
        progressTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 11.0.sp,
            fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18.0.sp,
            fontWeight: FontWeight.w600));
    Future<void> _handleSignUp() async {
      progressDialog.show();
      String token = await FirebaseMessaging.instance.getToken();
      User user = new User.from(
          name: _name,
          email: _email,
          cellNumber: _mobile,
          status: true,
          emailVerified: false,
          fcmToken: token,
          mobileApp: true);
      String key = await userService.save(user);
      if (key != null && key.isNotEmpty) {
        Credentials credentials = Credentials(
            userName: user.email, password: _password, userKey: key);
        await authenticationService.save(credentials);

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userKey', key);
        FirebaseMessaging.instance.subscribeToTopic(Topics.PROMOTIONS);
        FirebaseMessaging.instance.subscribeToTopic(Topics.MARKETING);
        progressDialog.hide();
        Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeft,
              child: AddressSearchPage(
                title: "Find Address",
                user: user,
              )),
        );
      } else {
        progressDialog.hide();
        Fluttertoast.showToast(
            msg: "UserName with email already exists",
            toastLength: Toast.LENGTH_LONG);
      }
    }
    Future<void> _sendOTP() async {
      String token = await FirebaseMessaging.instance.getToken();
      User user = new User.from(
          name: _name,
          email: _email,
          cellNumber: _mobile,
          status: true,
          emailVerified: false,
          fcmToken: token,
          mobileApp: true);
      Navigator.push(context, MaterialPageRoute(builder: (context) => OTPVerification(title: "Verification",user: user,)),);
    }
    void _validateForm() {
      if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
        _formKey.currentState.save();
        _sendOTP();
      } else {
//    If all data are not valid then start auto validation.
        setState(() {
          _autoValidate = true;
        });
      }
    }
    void toggleSwitch(bool value) {
      if(_terms == false) {
        setState(() {
          _terms = true;
        });
      }
      else{
        setState(() {
          _terms = false;
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
        body:SingleChildScrollView(
          child:Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 30.0.sp),
              child: new Text(
                'Join us for no more queues',
                style: new TextStyle(
                  fontSize: 17.0.sp,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0.sp),
              child: new Text(
                'Discover the perfect events',
                style: new TextStyle(
                  fontSize: 12.0.sp,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 40.0.sp,left: 10.0.sp,right: 10.0.sp),
                    child: nameField,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 7.0.sp,left: 10.0.sp,right: 10.0.sp),
                    child: emailField,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 7.0.sp,left: 10.0.sp,right: 10.0.sp),
                    child: cellField,
                  ),
                  ListTile(
                    title: Text(
                      'I agree with the Terms of Service & Privacy Policy',
                      style: new TextStyle(
                        fontSize: 11.0.sp,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    leading: Switch(
                      onChanged: toggleSwitch,
                      value: _terms,
                      activeColor: Colors.orange,
                      activeTrackColor: Colors.orange[100],
                    )  ,
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width.sp,
              margin: EdgeInsets.only(top:15.0.sp,left: 5.0.sp,right: 5.0.sp),
              height: 50.0.sp,
              child:  FlatButton(
                onPressed: _terms ? (){
                  _validateForm();
                }: null,
                child: new Text(
                  "Join",
                  style: new TextStyle(
                      fontSize: 17.0.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
                color: Colors.blue,
                disabledColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0.sp),
                    side: BorderSide(color: Colors.blue)
                ),
              ),
            ),
          ],
        )));
  }
}
