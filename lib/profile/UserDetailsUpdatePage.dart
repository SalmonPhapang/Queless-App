import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/auth/Authentication.dart';
import 'package:flutter_app/model/User.dart';
import 'package:flutter_app/service/UserService.dart';
import 'package:flutter_app/utils/TopWaveClipper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDetailsUpdatePage extends StatefulWidget {
  UserDetailsUpdatePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _UserDetailsUpdatePageState createState() => _UserDetailsUpdatePageState();

}

class _UserDetailsUpdatePageState extends State<UserDetailsUpdatePage> {
  TextStyle style = TextStyle(fontFamily: 'san-serif', fontSize: 15.0.sp);
  Auth auth = new Auth();
  UserService userService = new UserService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  String _name;
  String _email;
  String _mobile;
  String _lastName;
  String _password;
  User user;
  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
  }
  Future<User> getUser() async{
    final prefs = await SharedPreferences.getInstance();
    String  key = prefs.getString("userKey");
    this.user  =  await userService.fetchByKey(key);
    return this.user;
  }
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
    String validateEmail(String value) {
      Pattern pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = new RegExp(pattern);
      if (!regex.hasMatch(value))
        return 'Enter Valid Email';
      else
        return null;
    }
    ProgressDialog progressDialog = new ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: true, showLogs: false);
    progressDialog.style(
        message: 'Updating...',
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
      String key  = await userService.update(user);
      if(key != null && key.isNotEmpty){
        progressDialog.hide();
        Fluttertoast.showToast(msg: "Details updated successfully!",toastLength: Toast.LENGTH_LONG);
        Navigator.pop(context);
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
      elevation: 0.1,
      gradient: LinearGradient(colors: [Colors.cyan,Colors.indigo]),
      title: Text(widget.title),
    );
    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 245, 245, 1),
      appBar:topAppBar,
      body: FutureBuilder(
        future: getUser(),
    builder: (context,snapshot){
      if(snapshot.hasData){
        return  Container(
          margin: EdgeInsets.only(top: 20.0.sp),
          child:  new Column(
              children: <Widget>[
                new Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(5.sp),
                          child:TextFormField(
                            initialValue: this.user.name,
                            obscureText: false,
                            style: style,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            validator: validateName,
                            onSaved: (String value) {
                              this.user.name = value;
                            },
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0.sp, 15.0.sp, 20.0.sp, 15.0.sp),
                                hintText: "First Name",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
                          )//nameField,
                        ),
                        Padding(
                          padding: EdgeInsets.all(5.sp),
                          child:TextFormField(
                            initialValue: this.user.lastName,
                            obscureText: false,
                            style: style,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            validator: validateName,
                            onSaved: (String value) {
                              this.user.lastName = value;
                            },
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0.sp, 15.0.sp, 20.0.sp, 15.0.sp),
                                hintText: "Last Name",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
                          )//nameField,
                        ),
                        Padding(
                          padding: EdgeInsets.all(5.sp),
                          child: TextFormField(
                            initialValue: this.user.cellNumber,
                            obscureText: false,
                            style: style,
                            keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                            validator: validateMobile,
                            onSaved: (String value) {
                              this.user.cellNumber = value;
                            },
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0.sp, 15.0.sp, 20.0.sp, 15.0.sp),
                                hintText: "Cell Number",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
                          )//nameField,
                        ),
                        Padding(
                          padding: EdgeInsets.all(5.sp),
                          child:TextFormField(
                            initialValue: this.user.email,
                            obscureText: false,
                            style: style,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: validateEmail,
                            onSaved: (String value) {
                              this.user.email = value;
                            },
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0.sp, 15.0.sp, 20.0.sp, 15.0.sp),
                                hintText: "Email",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
                          )//emailField,
                        ),
                      ],
                    )),
                SizedBox(height: 5.0.sp,),
                Container(
                  margin: EdgeInsets.only(left: 5.sp,right: 5.sp),
                  width: MediaQuery.of(context).size.width,
                  child:  FlatButton(

                    onPressed: (){
                      _validateForm();
                    },
                    child: new Text(
                      "Update",
                      style: new TextStyle(
                          fontSize: 17.0.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                    ),
                    color: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(18.0.sp),
                        side: BorderSide(color: Colors.orangeAccent)
                    ),
                  ),
                ),
              ]
          ),
        );
      }else if(snapshot.hasError){
        return Text("${snapshot.error}");
      }else{
        return Center(child: SpinKitCubeGrid(color: Color(0xffff5722))) ;
      }
        })

    );
  }
}