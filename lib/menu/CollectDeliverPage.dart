import 'package:flutter/material.dart';
import 'package:flutter_app/menu/ClientMenuPage.dart';
import 'package:flutter_app/menu/OrderCart.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
class CollectDeliveryPage extends StatefulWidget {
  const CollectDeliveryPage({Key key}) : super(key: key);

  @override
  _CollectDeliveryPageState createState() => _CollectDeliveryPageState();
}

class _CollectDeliveryPageState extends State<CollectDeliveryPage> {
  @override
  void didChangeDependencies() {
    precacheImage(AssetImage("assets/images/scooter.jpg"), context);
    precacheImage(AssetImage("assets/images/store.jpg"), context);
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    var bloc = Provider.of<OrderCart>(context);
    final topAppBar = NewGradientAppBar(
      elevation: 0.1.sp,
      gradient: LinearGradient(colors: [Colors.cyan, Colors.indigo]),
      title: Text("Delivery or Collection"),
    ); //AppBar
    return  Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: topAppBar,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: (){
                  bloc.setOrderTypeMethod("Delivery");
                  Navigator.push(context,PageTransition(type: PageTransitionType.rightToLeft, child: ClientMenuPage(title: "Order From")),);
                },
                child: Card(
                  elevation: 5.sp,
                  child: Column(
                    children: <Widget>[
                        Image.asset("assets/images/scooter.jpg",width: 200.sp,fit: BoxFit.contain,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Delivery",style: TextStyle(fontSize: 15.0.sp,fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: (){
                  bloc.setOrderTypeMethod("Collection");
                  Navigator.push(context,PageTransition(type: PageTransitionType.rightToLeft, child: ClientMenuPage(title: "Order From")),);
                },
                child: Padding(
                  padding: EdgeInsets.only(top: 10.0.sp),
                  child: Card(
                    elevation: 5.sp,
                    child: Column(
                      children: <Widget>[
                        Image.asset("assets/images/store.jpg",width: 200.sp,fit: BoxFit.contain,),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Collection",style: TextStyle(fontSize: 15.0.sp,fontWeight: FontWeight.bold),),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
    );
  }

}
