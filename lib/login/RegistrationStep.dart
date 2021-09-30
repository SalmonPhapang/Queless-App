
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/adddress/AddressSearchPage.dart';
import 'package:flutter_app/auth/Authentication.dart';
import 'package:flutter_app/enums/Topics.dart';
import 'package:flutter_app/model/Credentials.dart';
import 'package:flutter_app/model/User.dart';
import 'package:flutter_app/service/AuthenticationService.dart';
import 'package:flutter_app/service/UserService.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
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
  final GlobalKey<FormState> _infoKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _accountKey = GlobalKey<FormState>();
  String _name;
  String _email;
  String _mobile;
  String _lastName;
  String _dateOfBirth;
  String _password;
  String _confirmPassword;
  TextEditingController password = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();
  DateTime currentDate = DateTime.now();
  DateTime pickedDate = DateTime.now();
  TextEditingController _dateController = TextEditingController();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime pickedDate = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(1920),
        lastDate: DateTime(2050));
    if (pickedDate != null && pickedDate != currentDate){
      if(currentDate.year - pickedDate.year >= 18){
        setState(() {
          this.pickedDate = pickedDate;
          _dateController.text = DateFormat.yMd().format(this.pickedDate);
          _dateOfBirth = _dateController.text;
        });
      }else{
        Fluttertoast.showToast(msg: "You have to be 18 years or older to use the app",toastLength: Toast.LENGTH_LONG);
      }
    }

  }
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
      if(currentDate.year - pickedDate.year < 18)
        return 'You have to be 18 years or older to use the app';
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
          labelText: "First Name",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
    );//nameField
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
    );//nameField
    final dateOfBirthField = TextFormField(
      obscureText: false,
      style: style,
      controller: _dateController,
      textInputAction: TextInputAction.next,
      validator: validateDateOfBirth,
      onTap: ()=>_selectDate(context),
      onSaved: (String value) {
        _dateOfBirth = value;
      },
      decoration: InputDecoration(
          labelText: "Date Of Birth",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
    );//dateField
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
          labelText: "Email",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
    );//emailField
    final passwordField = TextFormField(
      obscureText: true,
      controller: password,
      style: style,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      validator: validatePassword ,
      onSaved: (String value) {
        _password = value;
      },
      decoration: InputDecoration(
          labelText: "Password",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
    );// passwordField
    final confirmPasswordField = TextFormField(
      obscureText: true,
      controller: confirmpassword,
      style: style,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      validator: validateConfirmPassword ,
      onSaved: (String value) {
        _password = value;
      },
      decoration: InputDecoration(
          labelText: "Confirm Password",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
    );// passwordField
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
      String token = await FirebaseMessaging.instance.getToken();
      User user = new User.from(name: _name,lastName: _lastName,email: _email,cellNumber: _mobile,status: true,emailVerified: false,fcmToken: token,mobileApp: true);
      String key  = await userService.save(user);
      if(key != null && key.isNotEmpty){
        Credentials credentials = Credentials(userName: user.email,password: _password,userKey: key);
        await authenticationService.save(credentials);

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userKey', key);
        FirebaseMessaging.instance.subscribeToTopic(Topics.PROMOTIONS);
        FirebaseMessaging.instance.subscribeToTopic(Topics.MARKETING);
        progressDialog.hide();
        Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: AddressSearchPage(title: "Find Address",user: user,)),);
      }else{
        progressDialog.hide();
        Fluttertoast.showToast(msg: "UserName with email already exists",toastLength: Toast.LENGTH_LONG);
      }
    }
    void _validateAccountForm() {
      if (_accountKey.currentState.validate()) {
//    If all data are correct then save data to out variables
        _accountKey.currentState.save();
        _handleSignUp();
      }
    }
    bool _validateInfoForm() {
      if (_infoKey.currentState.validate()) {
//    If all data are correct then save data to out variables
        _infoKey.currentState.save();
        return true;
      }else{
        return false;
      }
    }
    tapped(int step){
      setState(() => _currentStep = step);
    }

    continued(){
      if(_currentStep == 0){
        if(_validateInfoForm()){
          _currentStep < 2 ?
          setState(() => _currentStep += 1): null;
        }
      }else if(_currentStep >= 1){
        _validateAccountForm();
      }
    }
    cancel(){
      _currentStep > 0 ?
      setState(() => _currentStep -= 1) : null;
    }
    final topAppBar = NewGradientAppBar(
      elevation: 0.1.sp,
      gradient: LinearGradient(colors: [Colors.cyan,Colors.indigo]),
      title: Text(widget.title),
    );
    return  Scaffold(
      appBar: topAppBar,
      body: Column(
        children: <Widget>[
          Expanded( child: Theme(
            data: ThemeData(
                colorScheme: ColorScheme.light(
                    primary: Colors.blue
                )
            ),
            child: Stepper(
              type: StepperType.vertical,
              physics: ScrollPhysics(),
              currentStep: _currentStep,
              onStepTapped: (step)=> tapped(step),
              onStepContinue:  continued,
              onStepCancel: cancel,
              steps: <Step>[
                Step(
                  title: const Text('Personal Info'),
                  content: new Form(
                          key: _infoKey,
                          autovalidateMode: AutovalidateMode.disabled,
                          child:  Column(
                            children: <Widget>[
                              Padding(
                                padding:  EdgeInsets.only(top: 10.0.sp),
                                child: nameField,
                              ),
                              Padding(
                                padding:  EdgeInsets.only(top: 10.0.sp),
                                child:lastNameField,
                              ),
                              Padding(
                                padding:  EdgeInsets.only(top: 10.0.sp),
                                child: cellField,
                              ),
                              Padding(
                                padding:  EdgeInsets.only(top: 10.0.sp),
                                child: dateOfBirthField,
                              )
                            ],
                          ),
                  ),
                  isActive: _currentStep >= 0,
                  state: _currentStep >= 0 ?
                  StepState.complete : StepState.disabled,
                ),
                Step(
                  title: new Text('Account'),
                  content: new Form(
                        key: _accountKey,
                        autovalidateMode: AutovalidateMode.disabled,
                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 10.0.sp),
                        child: emailField,
                      ),
                      Padding(
                        padding:  EdgeInsets.only(top: 10.0.sp),
                        child: passwordField,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 2.0.sp),
                        child: new FlutterPwValidator(
                            controller: password,
                            minLength: 8,
                            uppercaseCharCount: 1,
                            numericCharCount: 1,
                            specialCharCount: 1,
                            width: 400.sp,
                            height: 130.sp,
                            onSuccess: ()=>{

                            }
                        ),
                      ),
                      Padding(
                        padding:  EdgeInsets.only(top: 10.0.sp),
                        child: confirmPasswordField,
                      ),
                    ],
                  )),
                  isActive: _currentStep >= 0,
                  state: _currentStep >= 1 ?
                  StepState.complete : StepState.disabled,
                ),
              ],
            ),
          ))
        ],
      )
    );

  }


}