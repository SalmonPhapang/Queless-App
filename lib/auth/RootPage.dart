import 'package:flutter/material.dart';
import 'package:flutter_app/HomePage.dart';
import 'package:flutter_app/auth/Authentication.dart';
import 'package:flutter_app/login/loginPage.dart';
import 'package:flutter_app/main.dart';

class RootPage extends StatefulWidget {

  Auth auth;
  RootPage({this.auth});

  @override
  State<StatefulWidget>createState() => RootPageState();
}

enum AuthStatus { notSignedIn, signedIn }

class RootPageState extends State<RootPage> {

  AuthStatus _authStatus = AuthStatus.notSignedIn;

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((userId) {
      setState(() {
        _authStatus = userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    switch(_authStatus){
      case AuthStatus.notSignedIn :
        return new LoginPage(title: "Login",);
      case AuthStatus.signedIn :
        return new BottomNavBar();
    }

  }
}