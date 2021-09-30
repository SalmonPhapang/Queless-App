import 'package:flutter/material.dart';
import 'package:flutter_app/enums/OrderStatus.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/model/Order.dart';
import 'package:flutter_app/service/OrderService.dart';
import 'package:flutter_app/utils/TopWaveClipper.dart';
import 'package:flutter_app/widgets/Avatar.dart';
import 'package:flutter_app/widgets/ProgressBar.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';
class OrderTracker extends StatefulWidget {
  OrderTracker({Key key, this.order,this.willPop}) : super(key: key);
  final bool willPop;
  final Order order;

  @override
  _OrderTrackerState createState() => _OrderTrackerState();
}

class _OrderTrackerState extends State<OrderTracker> with TickerProviderStateMixin {
  // final timerDuration = Duration(milliseconds: 2500);
  TabController tabController;
  final imageOne = "assets/images/confirm.png";
  final textOne = "Order confirmed";
  final imageTwo = "assets/images/fried.png";
  final textTwo = "Order is being prepared";
  final imageThree = "assets/images/food-delivery.png";
  final textThree = "Order is on the way";
  final imageFour = "assets/images/wedding-dinner.png";
  final textFour = "Order Collected Enjoy :)";
  OrderService orderService = new OrderService();

  @override

  void initState() {
    super.initState();
    int initialIndex = 0;
    if (widget.order.orderStatus.contains(OrderStatus.PLACED)) {
      setState(() {
        initialIndex = 0;
      });
    }else  if (widget.order.orderStatus.contains(OrderStatus.ACCEPTED_BY_CLIENT)) {
      setState(() {
        initialIndex = 1;
      });
    } else if (widget.order.orderStatus.contains(OrderStatus.PREPARED)) {
      setState(() {
        initialIndex = 2;
      });
    }else if (widget.order.orderStatus.contains(OrderStatus.DELIVERED) || widget.order.orderStatus.contains(OrderStatus.CANCELLED)) {
      setState(() {
        initialIndex = 3;
      });
    }
    tabController = TabController(vsync: this, length: 4,initialIndex: initialIndex);
    tabController.addListener(() {
      if (widget.order.orderStatus.contains(OrderStatus.PLACED)) {
        setState(() {
          tabController.index = 0;
        });
      }else  if (widget.order.orderStatus.contains(OrderStatus.ACCEPTED_BY_CLIENT)) {
        setState(() {
          tabController.index = 1;
        });
      } else if (widget.order.orderStatus.contains(OrderStatus.PREPARED)) {
        setState(() {
          tabController.index = 2;
        });
      }else if (widget.order.orderStatus.contains(OrderStatus.DELIVERED) || widget.order.orderStatus.contains(OrderStatus.CANCELLED)) {
        setState(() {
          tabController.index = 3;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final topAppBar = NewGradientAppBar(
      elevation: 5.sp,
      gradient: LinearGradient(colors: [Colors.cyan,Colors.indigo]),
      title: Padding(
        child: Text("Track  Order"),
        padding: EdgeInsets.only(top: 12.sp),
      ),
      actions: <Widget>[
        !widget.willPop ? IconButton(
          icon: Icon(
            Icons.home_outlined,
            color: Colors.white,
            size: 20.0.sp,
          ),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              PageTransition(type: PageTransitionType.rightToLeft, child: BottomNavBar()),
                  (route) => false,
            );
          },
        ) : Container()
      ],
      bottom: TabBar(
        tabs: <Widget>[
          Tab(child: Text("Confirm",
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.0.sp,
                fontFamily: "Calibre-Semibold",
              )),),
          Tab(child: Text("Preparation",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.2.sp,
                fontFamily: "Calibre-Semibold",
              )),),
          Tab(child: Text("On Its Way",
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.0.sp,
                fontFamily: "Calibre-Semibold",
              )),),
          Tab(child: Text("Delivered",
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.0.sp,
                fontFamily: "Calibre-Semibold",
              )),)
        ],
        indicatorColor:Colors.white ,
        controller: tabController,
      ),
    );
    return WillPopScope(
      onWillPop: () => Future.value(widget.willPop),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar:topAppBar,
        body:new Stack(
            children: <Widget>[
              TabBarView(
                  controller: tabController,
                  physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    Center(
                      child:Container(
                        height: 250.sp,
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Image.asset(imageOne, width: 125.sp),
                            ),
                            SizedBox(height: 15.sp),
                            Text(
                              textOne,
                              style: TextStyle(
                                  color: Colors.black, fontSize: 20.sp, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child:   Container(
                        height: 250.sp,
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Image.asset(imageTwo, width: 125.sp),
                            ),
                            SizedBox(height: 15.sp),
                            Text(
                              textTwo,
                              style: TextStyle(
                                  color: Colors.black, fontSize: 20.sp, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        height: 250.sp,
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Image.asset(imageThree, width: 125.sp),
                            ),
                            SizedBox(height: 15.sp),
                            Text(
                              textThree,
                              style: TextStyle(
                                  color: Colors.black, fontSize: 20.sp, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        height: 250.sp,
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Image.asset(imageFour, width: 125.sp),
                            ),
                            SizedBox(height: 15.sp),
                            Text(
                              textFour,
                              style: TextStyle(
                                  color: Colors.black, fontSize: 20.sp, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),

              Positioned(
                  bottom: 0.0.sp,
                  child:  InkWell(
                    child: Card(
                      elevation: 10.0.sp,
                      margin: EdgeInsets.all(5.0.sp),
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.topRight,
                                colors:TopWaveClipper.orangeGradients
                            )
                        ),
                        width: MediaQuery.of(context).size.width.sp - 10.0.sp,
                        height: 50.0.sp,
                        child: Center(
                          child: Text(' View Order #'+widget.order.orderNumber,style: TextStyle(color: Colors.white,fontSize: 16.0.sp),),
                        ),
                      ) ,
                    ) ,
                    onTap: ()=>{
                      viewOrderBottomSheet(context)
                    },
                  )
              )
            ])
    )
    );

  }
  void viewOrderBottomSheet(context){
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc){
          return Container(
            child: new Wrap(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(bottom: 10.0.sp,top: 10.0.sp),
                  child:  Center(
                    child: Text('Order Details',style: TextStyle(color: Colors.black87,fontSize: 18.0.sp,fontWeight:FontWeight.bold )),
                  ),
                ),
                new ListTile(
                  leading: new Icon(Icons.calendar_today_outlined),
                  title: new Text(widget.order.address.houseNumber),
                ),
                new ListTile(
                    leading: new Icon(Icons.location_on_outlined),
                    title: new Text(widget.order.address.houseNumber+' '+widget.order.address.streetName+' '+widget.order.address.addressLine +' '+widget.order.address.suburb+' '+widget.order.address.city+' '+widget.order.address.province+' '+widget.order.address.code),
                ),
                new ListTile(
                  leading: new Icon(Icons.money),
                  title: new Text(widget.order.total.toString()),
                ),
                new ListTile(
                  leading: new Icon(Icons.track_changes_outlined),
                  title: new Text(widget.order.orderStatus),
                ),
                Visibility(
                  visible: widget.order.collection,
                  child: new ListTile(
                    leading: new Icon(Icons.store),
                    title: new Text("Collection"),
                  ),
                ),
                Visibility(
                  visible:widget.order.delivery ,
                  child: new ListTile(
                    leading: new Icon(Icons.delivery_dining),
                    title: new Text("Delivery"),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }
}