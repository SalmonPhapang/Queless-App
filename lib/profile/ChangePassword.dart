import 'package:flutter/material.dart';
import 'package:flutter_app/model/User.dart';
import 'package:flutter_app/service/UserService.dart';
import 'package:flutter_app/utils/TopWaveClipper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordPage extends StatefulWidget {
  ChangePasswordPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}
class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextStyle style = TextStyle(fontFamily: 'san-serif', fontSize: 20.0.sp);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _password;
  String _confirmPassword;
  UserService userService = new UserService();
  TextEditingController password = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();

  void signOut() async{
    final prefs = await SharedPreferences.getInstance();
    String key = prefs.getString('userKey');

    User user = await userService.fetchByKey(key);
    user.password = this._password;
    userService.update(user);
    Fluttertoast.showToast(msg: "Password changed successfully!",toastLength: Toast.LENGTH_LONG);
    Navigator.pop(context);
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
    String validateConfirmPassword(String value){
        if (password.text != confirmpassword.text) {
            return "Password does not match";
        }else{
          return null;
        }
    }
    void _validateForm() {
      if (_formKey.currentState.validate()) {
         _formKey.currentState.save();
         signOut();
      }
    }
    final topAppBar = NewGradientAppBar(
      elevation: 0.1,
      gradient: LinearGradient(colors: [Colors.cyan,Colors.indigo]),
      title: Text(widget.title),
    );
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: topAppBar,
        body: Container(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15,left: 10,right: 10),
                    child: TextFormField(
                      controller: password,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      decoration:InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          hintText: "Current Password",
                          border:
                          OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
                      validator:validatePassword,
                      onSaved: (String value) {
                        _password = value;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15,left: 10,right: 10),
                    child: TextFormField(
                      controller: confirmpassword,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      decoration:InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          hintText: "Confirm Password",
                          border:
                          OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
                      validator: validateConfirmPassword,
                      onSaved: (String value) {
                        _confirmPassword = value;
                      },
                    ),
                  ),
                  new InkWell(
                    onTap: () {
                      _validateForm();
                    },
                    child: new Container(
                      width: MediaQuery.of(context).size.width,
                      height: 40.0.sp,
                      margin: EdgeInsets.only(left: 5.0.sp,right: 5.0.sp),
                      padding: EdgeInsets.only(top: 8.sp),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5.0.sp)),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.topRight,
                              colors:TopWaveClipper.orangeGradients
                          )
                      ),
                      child: new Text(
                        'Save',
                        softWrap: true,
                        style: new TextStyle(
                            fontSize: 19.0.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),)
                ],
              ),
            ),)
    );
  }

}