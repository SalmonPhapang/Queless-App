import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/HomePage.dart';
import 'package:flutter_app/auth/Authentication.dart';
import 'package:flutter_app/login/loginPage.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/model/User.dart';
import 'package:flutter_app/model/Constants.dart';
import 'package:flutter_app/utils/TopWaveClipper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationPage extends StatefulWidget {
  RegistrationPage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 15.0);
  Auth auth = new Auth();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  String _name;
  String _email;
  String _mobile;
  String _password;
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
    final nameField = TextFormField(
      obscureText: false,
      style: style,
      keyboardType: TextInputType.text,
      validator: validateName,
      onSaved: (String value) {
        _name = value;
      },
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Name & Surname",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );//nameField
    final cellField = TextFormField(
      obscureText: false,
      style: style,
      keyboardType: TextInputType.phone,
      inputFormatters:<TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly
      ] ,
      validator: validateMobile,
      onSaved: (String value) {
        _mobile = value;
      },
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Cell Number",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );//nameField
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
        message: 'Signing Up...',
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
    Future<void> _handleSignUp() async{
      progressDialog.show();
      String uid = await auth.signUp(_email, _password);
      User user = new User(uid,_name, _email, _password, _mobile,null);
      DatabaseReference postsReference = FirebaseDatabase.instance.reference().child("Users");
      postsReference.child(uid).set(user.toJson()).whenComplete((){
        progressDialog.hide();
        Fluttertoast.showToast(msg: "Welcome "+ user.name,toastLength: Toast.LENGTH_LONG);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavBar()),);
      });
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
                      height: ScreenUtil().setHeight(MediaQuery.of(context).size.height / 2.9),
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
                  )
                ],
              ),
              new Form(
                  key: _formKey,
                  autovalidate: _autoValidate,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(5),
                        child:nameField,
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child:cellField,
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child:emailField,
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: passwordField,
                      ),
                    ],
                  )),
              SizedBox(height: 5.0,),
              new Column(
                children: <Widget>[
                  SizedBox(height: ScreenUtil().setHeight(10.0),),
                  new Center(child: new Text(
                    "By tapping 'Sign Up' you aggree to the ",
                    style: new TextStyle(
                        fontSize: ScreenUtil().setSp(18.0),
                        color: Colors.black54,
                        fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.center,
                  )),
                  SizedBox(height: ScreenUtil().setHeight(5.0),),
                ],
              ),
              Container(
                width: ScreenUtil().setWidth(250.0),
                child:  FlatButton(
                  onPressed: (){
                    _validateForm();
                  },
                  child: new Text(
                    "Sign Up",
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
              Padding(
                padding: EdgeInsets.only(top:ScreenUtil().setHeight(20)),
                child:  InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: new Center(child:  Text.rich(
                        TextSpan(
                            style: new TextStyle(
                                fontSize: ScreenUtil().setSp(20.0),
                                color: Colors.black54,
                                fontWeight: FontWeight.bold
                            ),
                            text: "Already have account? ",
                            children: <TextSpan>[
                              TextSpan(
                                text: "Login",
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
      ),

    );

  }

}