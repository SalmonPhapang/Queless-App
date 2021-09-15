import 'package:flutter/material.dart';
import 'package:flutter_app/login/RegistrationPage.dart';
import 'package:flutter_app/login/RegistrationStep.dart';
import 'package:flutter_app/login/loginPage.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class IntroPage extends StatefulWidget {
  const IntroPage({Key key}) : super(key: key);

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    List<PageViewModel> getPages() {
      return [
        PageViewModel(
            image: Image.asset("assets/images/order.jpg"),
            title: "Find your flavour",
            body: "Easy and quick way to order food and drinks from local spots",
            ),
        PageViewModel(
          image: Image.asset("assets/images/food.jpg"),
          title: "Choose your meal",
          body: "Wide and diverse range of meals available for any person",
        ),
        PageViewModel(
          image: Image.asset("assets/images/scooter.jpg"),
          title: "Delivered Fast",
          body: "Get food delivered in minutes, we deliver you enjoy :)",
        ),
        PageViewModel(
          image: Image.asset("assets/images/Delivery.jpg"),
          title: "Easy tracking and order management",
          body: "Receive notifications and easy tracking of your order",
        ),
      ];
    }
    final topAppBar = NewGradientAppBar(
      elevation: 0.1.sp,
      gradient: LinearGradient(colors: [Colors.cyan, Colors.indigo]),
      title: Text("Intro"),
    ); //AppBar
    return Scaffold(
      appBar:topAppBar,
      body:  IntroductionScreen(
        globalFooter:   Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 10.0.sp),
              child: TextButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(title: "LogIn",)),);
                },
                child: new Text(
                  "Login",
                  style: new TextStyle(
                      fontSize: 18.sp,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 10.0.sp),
              child: TextButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationStepPage(title: "Set up account")),);
                },
                child: new Text(
                  "Register",
                  style: new TextStyle(
                      fontSize: 18.sp,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        ),
        globalBackgroundColor: Colors.white,
        pages: getPages(),
        showDoneButton: false,
        showNextButton: false,
        dotsDecorator: DotsDecorator(
            size: const Size.square(10.0),
            activeSize: const Size(20.0, 10.0),
            activeColor: Colors.orangeAccent,
            color: Colors.black26,
            spacing: const EdgeInsets.symmetric(horizontal: 3.0),
            activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)
            )
        ),
      ),

    );
  }
}
