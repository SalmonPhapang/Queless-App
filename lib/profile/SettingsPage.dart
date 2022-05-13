import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/enums/Topics.dart';
import 'package:flutter_app/login/loginPage.dart';
import 'package:flutter_app/model/User.dart';
import 'package:flutter_app/profile/ChangePassword.dart';
import 'package:flutter_app/profile/PrivacyAndTermsPage.dart';
import 'package:flutter_app/profile/UserDetailsUpdatePage.dart';
import 'package:flutter_app/service/UserService.dart';
import 'package:intl/intl.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool promotionEnabled =  true;
  bool marketingEnabled =  true;
  UserService userService = new UserService();

  @override
  Widget build(BuildContext context) {
    final topAppBar = NewGradientAppBar(
      elevation: 0.1,
      gradient: LinearGradient(colors: [Colors.cyan, Colors.indigo]),
      title: Text(widget.title),
    );

    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: topAppBar,
        body: Container(
          margin: EdgeInsets.only(top: 10.0.sp),
          child:SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 10.sp,left: 10.0.sp),
                  child:  Text(
                    "Account",
                    style: TextStyle(color: Colors.grey[700], fontSize: 16.0.sp),
                  ),
                ),
                new Card(
                    elevation: 1.0,
                    shadowColor: Colors.grey[100],
                    child: new Container(
                        child: new Column(
                          children: <Widget>[
                            new ListTile(
                              title:  Text(
                                "Personal Details",
                                style: TextStyle(color: Colors.grey[700], fontSize: 14.0.sp),
                              ),
                              trailing: new Icon(Icons.arrow_forward_ios_sharp,size: 20.0.sp,),
                              onTap: ()=>{
                                Navigator.push(context, MaterialPageRoute(builder: (context) => UserDetailsUpdatePage(title: "Change Details")),)
                              },
                            ),
                            new ListTile(
                              title:  Text(
                                "Change Password",
                                style: TextStyle(color: Colors.grey[700], fontSize: 14.0.sp),
                              ),
                              trailing: new Icon(Icons.arrow_forward_ios_sharp,size: 20.0.sp,),
                              onTap: ()=>{
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordPage(title: "Change Password")),)
                              },
                            ),
                          ],
                        )
                    )
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.sp,left: 10.0.sp),
                  child: Text(
                    "Notifications",
                    style: TextStyle(color: Colors.grey[700], fontSize: 16.0.sp),
                  ),
                ),
                new Card(
                    elevation: 1.0,
                    shadowColor: Colors.grey[100],
                    child: new Container(
                        child: new Column(
                          children: <Widget>[
                            new ListTile(
                              title:  Text(
                                "Promotional Content",
                                style: TextStyle(color: Colors.grey[700], fontSize: 14.0.sp),
                              ),
                              trailing: Switch(
                                onChanged: (value) {
                                  promotionEnabled = value;
                                  if(promotionEnabled){
                                    FirebaseMessaging.instance.subscribeToTopic(Topics.PROMOTIONS);
                                  }else{
                                    FirebaseMessaging.instance.unsubscribeFromTopic(Topics.PROMOTIONS);
                                  }
                                  setState(() {});
                                },
                                activeTrackColor: Colors.lightBlueAccent,
                                activeColor: Colors.blue,
                                value: promotionEnabled,
                              ),
                            ),
                            new ListTile(
                              title:  Text(
                                "Marketing Content",
                                style: TextStyle(color: Colors.grey[700], fontSize: 14.0.sp),
                              ),
                              trailing: Switch(
                                onChanged: (value) {
                                  marketingEnabled = value;
                                  if(marketingEnabled){
                                    FirebaseMessaging.instance.subscribeToTopic(Topics.MARKETING);
                                  }else{
                                    FirebaseMessaging.instance.unsubscribeFromTopic(Topics.MARKETING);
                                  }
                                  setState(() {});
                                },
                                activeTrackColor: Colors.lightBlueAccent,
                                activeColor: Colors.blue,
                                value: marketingEnabled,
                              ),
                            ),
                          ],
                        )
                    )
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.sp,left: 10.0.sp),
                  child:   Text(
                    "Other",
                    style: TextStyle(color: Colors.grey[700], fontSize: 16.0.sp),
                  ),
                ),

                new Card(
                    elevation: 1.0,
                    shadowColor: Colors.grey[100],
                    child: new Container(
                        child: new Column(
                          children: <Widget>[
                            new ListTile(
                              title:  Text(
                                "Privacy Policy",
                                style: TextStyle(color: Colors.grey[700], fontSize: 14.0.sp),
                              ),
                              trailing: new Icon(Icons.arrow_forward_ios_sharp,size: 20.0.sp,),
                              onTap: ()=>{
                              Navigator.push(context, MaterialPageRoute(builder: (context) => TermsPrivacyPage(title: "Privacy Policy",isTerms: false,)),)
                              },
                            ),
                            new ListTile(
                              title:  Text(
                                "Terms Of Use",
                                style: TextStyle(color: Colors.grey[700], fontSize: 14.0.sp),
                              ),
                              trailing: new Icon(Icons.arrow_forward_ios_sharp,size: 20.0.sp,),
                              onTap: ()=>{
                                Navigator.push(context, MaterialPageRoute(builder: (context) => TermsPrivacyPage(title: "Privacy Policy",isTerms: true,)),)
                              },
                            ),
                            new ListTile(
                              title:  Text(
                                "Delete Account",
                                style: TextStyle(color: Colors.grey[700], fontSize: 14.0.sp),
                              ),
                              trailing: new Icon(Icons.arrow_forward_ios_sharp,size: 20.0.sp,),
                              onTap: () {
                                showDeleteAlertDialog(context);
                              },
                            ),
                            new ListTile(
                              title:  Text(
                                "Sign Out",
                                style: TextStyle(color: Colors.grey[700], fontSize: 14.0.sp),
                              ),
                              trailing: new Icon(Icons.arrow_forward_ios_sharp,size: 20.0.sp,),
                              onTap: () {
                                  showSignOutAlertDialog(context);
                              },
                            ),
                          ],
                        )
                    )
                ),
              ],
            ),
          )

        ));
  }

  void signOut() async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userKey',null);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage(title: "Login")),);
  }
  void removeAccount() async{
    final prefs = await SharedPreferences.getInstance();
    String key = prefs.getString("userKey");

    await userService.archive(key);
    prefs.setString('userKey',null);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage(title: "Login")),);
  }
  showSignOutAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text("Notice"),
      content: Text("You are about to sign out. Is this what you intended to do?"),
      actions: [
    TextButton(
    child: Text("Continue"),
        onPressed:  () {
          Navigator.pop(context);
          signOut();
        },
    ),
    TextButton(
    child: Text("Cancel"),
      onPressed:  () {
        Navigator.pop(context);
      },
    ),
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  showDeleteAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text("Notice"),
      content: Text("You are about to remove your account. Is this what you intended to do?"),
      actions: [
        TextButton(
          child: Text("Continue"),
          onPressed:  () {
            Navigator.pop(context);
            removeAccount();
          },
        ),
        TextButton(
          child: Text("Cancel"),
          onPressed:  () {
            Navigator.pop(context);
          },
        ),
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
