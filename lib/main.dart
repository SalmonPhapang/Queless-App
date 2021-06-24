import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/ScanScreen.dart';
import 'package:flutter_app/HomePage.dart';
import 'package:flutter_app/MapsPage.dart';
import 'package:flutter_app/Story.dart';
import 'package:flutter_app/auth/Authentication.dart';
import 'package:flutter_app/auth/RootPage.dart';
import 'package:flutter_app/login/loginPage.dart';
import 'package:flutter_app/menu/OrderCart.dart';
import 'package:flutter_app/utils/BottomWaveClipper.dart';
import 'package:flutter_app/utils/TopWaveClipper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:splash_screen_view/SplashScreenView.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: Size(360, 690),
        builder: () => ChangeNotifierProvider<OrderCart>(
          create: (_) => OrderCart(),
          child: new MaterialApp(
            title: "Queless",
            debugShowCheckedModeBanner: false,
            theme: new ThemeData(
                primarySwatch: Colors.blue
            ),
            home: new SplashScreenView(
              navigateRoute:  new RootPage(auth: new Auth()),
              duration: 5000,
              imageSize: 130,
              imageSrc: "assets/logo.png",
              text: "Welcome",
              textType: TextType.ColorizeAnimationText,
              textStyle: TextStyle(
                fontSize: 25.0,
              ),
              colors: BottomWaveClipper.primaryGradients,
              backgroundColor: Colors.white,
            ),

          ),
        )
    );
  }

}

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _page = 0;
  GlobalKey _bottomNavigationKey = GlobalKey();

  final _pageOption = [
    HomePage(title:"Social"),
    ScanScreen(title: "Scan",),
    MapsPage(title:"Map"),
    Story(title: "Profile")
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: 0,
          height: 50.0,
          items: <Widget>[
            Icon(Icons.home, size: 30),
            Icon(Icons.camera, size: 30),
            Icon(Icons.location_on, size: 30),
            Icon(Icons.perm_identity, size: 30),
          ],
          color: Colors.white,
          buttonBackgroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 600),
          onTap: (index) {
            setState(() {
              _page = index;
            });
          },
        ),
        body: _pageOption[_page],
      backgroundColor: Color.fromRGBO(245, 245, 245, 1),
    );
  }
}