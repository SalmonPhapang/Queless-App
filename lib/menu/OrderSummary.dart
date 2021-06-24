import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/auth/Authentication.dart';
import 'package:flutter_app/menu/OrderTracking.dart';
import 'package:flutter_app/model/Address.dart';
import 'package:flutter_app/model/Constants.dart';
import 'package:flutter_app/model/Order.dart';
import 'package:flutter_app/model/User.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'OrderCart.dart';

class OrderSummary extends StatefulWidget {
  @override
  _OrderSummaryState createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {
  double itemTotal = 0.0;
  double fee = 30.0;
  double total = 0.0;
  String orderType;
  String paymentMethod;
  Auth auth = new Auth();
  User _user;

  ProgressDialog progressDialog;
  List<Row> generateOrderTotals(OrderCart cart){
    List<Row> rows = new List<Row>();
    itemTotal = 0.0;
    fee = 30.0;
    total = 0.0;
    for(var item in cart.cart){
      itemTotal += item.price;
    }
    total = itemTotal + fee;
    rows.add(new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 10,bottom: 10,top: 10),
          child: new Text(
            'Subtotal',
            softWrap: true,
            style: new TextStyle(
                fontSize: 13.0,
                color: Colors.black87,
                fontWeight: FontWeight.normal
            ),
            textAlign: TextAlign.end,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 20,bottom: 10),
          child: new Text(
            "R"+'$itemTotal',
            softWrap: true,
            style: new TextStyle(
                fontSize: 13.0,
                color: Colors.black87,
                fontWeight: FontWeight.normal
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    ));
    rows.add(new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 10,bottom: 10),
          child: new Text(
            'Service fee',
            softWrap: true,
            style: new TextStyle(
                fontSize: 13.0,
                color: Colors.black87,
                fontWeight: FontWeight.normal
            ),
            textAlign: TextAlign.end,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 20,bottom: 10),
          child: new Text(
            "R"+'$fee',
            softWrap: true,
            style: new TextStyle(
                fontSize: 13.0,
                color: Colors.black87,
                fontWeight: FontWeight.normal
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    ));
    rows.add(new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 10,bottom: 10),
          child: new Text(
            'Total',
            softWrap: true,
            style: new TextStyle(
                fontSize: 13.0,
                color: Colors.black87,
                fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.end,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 20),
          child: new Text(
            "R"+'$total',
            softWrap: true,
            style: new TextStyle(
                fontSize: 13.0,
                color: Colors.black87,
                fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    ));

    return rows;
  }
  @override
  void initState() {
    super.initState();
    getUser();
  }
  getUser() async{
    firebaseAuth.User user = await auth.getCurrentUser();
    Query userReference  = FirebaseDatabase.instance.reference().child("Users").child(user.uid);
    await  userReference.once().then((DataSnapshot snapshot){
      this.setState(() {
        Map data = snapshot.value;
        Map address = data['Addresses'];
        Map<String,Address> addressMap = new Map();
        address.forEach((key, value) {
          Address address = new Address();
          addressMap.putIfAbsent(key, () => address);
        });
        addressMap.remove(null);
        setState(() {
          _user = new User(user.uid,   data["name"],   data["email"],    data["password"],   data["cellNumber"],addressMap);
        });
      });
    });
  }
  saveNewOrder(OrderCart cart) async{
    progressDialog.show();
    firebaseAuth.User user = await auth.getCurrentUser();
    Order order = new Order("", Constants.orderABV+createRandomOrderNumber(), DateTime.now().toString(), cart.cart, total, itemTotal, fee,orderType,paymentMethod,cart.address.key);
    FirebaseDatabase.instance.reference().child("Users").child(user.uid).child("orders").push().set(order.toJson()).whenComplete((){
      progressDialog.hide();
      cart.clearAll();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OrderTracker()),);
    });

  }
  String createRandomOrderNumber(){
    Random aRandom = new Random();
    String sequence ="";
    for (int i = 1; i <= 5; i++) {
      int aStart = 1;
      int aEnd = 10;
      //get the range, casting to long to avoid overflow problems
      int range = aEnd - aStart + 1;
      // compute a fraction of the range, 0 <= frac < range
      int fraction = range * aRandom.nextInt(10);
      int randomNumber = fraction + aStart;
      sequence = sequence + randomNumber.toString();

    }

    return sequence;

  }

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<OrderCart>(context);
    final topAppBar = NewGradientAppBar(
      elevation: 0.1,
      gradient: LinearGradient(colors: [Colors.cyan,Colors.indigo]),
      title: Text("Order Summary"),
    );
    progressDialog = new ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: true, showLogs: false);
    progressDialog.style(
        message: 'Submitting Order',
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
    return Scaffold(
      backgroundColor: Colors.white,
        appBar: topAppBar,
        body: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 10,bottom: 10,top: 10),
                    child: new Text(
                      'Delivery Details',
                      softWrap: true,
                      style: new TextStyle(
                          fontSize: 16.0,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),

                  new Card(
                    elevation: 10.0,
                    margin:EdgeInsets.all(3.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 10,bottom: 10,top: 10),
                          child: new Text(
                            "",
                            softWrap: true,
                            style: new TextStyle(
                                fontSize: 16.0,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Center(
                          child: ToggleSwitch(
                            initialLabelIndex: 0,
                            totalSwitches: 3,
                            minHeight: 35,
                            minWidth: 100,
                            cornerRadius: 5.0,
                            activeBgColor: [Color(0xFF0EDED2)],
                            activeFgColor: Colors.white,
                            inactiveBgColor: Colors.grey,
                            inactiveFgColor: Colors.white,
                            labels: ['Collection', 'Delivery'],
                            iconSize: 12,
                            onToggle: (index) {
                                switch(index){
                                  case 0:
                                    setState(() {
                                      orderType = 'Collection';
                                    });
                                    break;
                                  case 1:
                                    setState(() {
                                      orderType = 'Delivery';
                                    });
                                    break;
                                }
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10,top: 10),
                          child: new Text(
                            'Contact Details: ',
                            softWrap: true,
                            style: new TextStyle(
                                fontSize: 12.0,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 10,top: 5),
                              child: new Text(
                                _user != null ? _user.name.trim() :'',
                                softWrap: true,
                                style: new TextStyle(
                                    fontSize: 10.0,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10,bottom: 5,top: 5),
                              child: new Text(
                                _user != null ? _user.cellNumber.trim() : '',
                                softWrap: true,
                                style: new TextStyle(
                                    fontSize: 10.0,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ],
                        )

                      ],


                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10,bottom: 10,top: 10),
                    child: new Text(
                      'Payment Method',
                      softWrap: true,
                      style: new TextStyle(
                          fontSize: 16.0,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),

      new Card(
        elevation: 10.0,
        margin:EdgeInsets.all(3.0),
          child: Container(
            margin:EdgeInsets.only(top:15.0,bottom: 15),
              width: MediaQuery.of(context).size.width,
              child:Center(
                child: ToggleSwitch(
                  initialLabelIndex: 0,
                  totalSwitches: 3,
                  minHeight: 35,
                  minWidth: 80,
                  cornerRadius: 5.0,
                  activeBgColor:[Color(0xFF0EDED2)],
                  activeFgColor: Colors.white,
                  inactiveBgColor: Colors.grey,
                  inactiveFgColor: Colors.white,
                  labels: ['Cash', 'Card','Points'],
                  iconSize: 12,
                  icons: [FontAwesomeIcons.moneyBillWave, FontAwesomeIcons.creditCard,FontAwesomeIcons.crown],
                  onToggle: (index) {
                    switch(index){
                      case 0:
                        setState(() {
                          paymentMethod = 'Cash';
                        });
                        break;
                      case 1:
                        setState(() {
                          paymentMethod = 'Card';
                        });
                        break;
                      case 2:
                        setState(() {
                          paymentMethod = 'Points';
                        });
                        break;
                    }
                  },
                ),
              )
          ),
      ),


                  Padding(
                    padding: EdgeInsets.only(left: 10,bottom: 10,top: 10),
                    child: new Text(
                      'Order',
                      softWrap: true,
                      style: new TextStyle(
                          fontSize: 16.0,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
             new Card(
                elevation: 10.0,
                margin:EdgeInsets.all(3.0),
                child: new Column(
                  crossAxisAlignment:CrossAxisAlignment.start ,
                  mainAxisSize : MainAxisSize.min,
                  children : <Widget>[
                   Column(
                     children:generateOrderTotals(cart),
                   ) ,
                  ],


                )//Column,
            ),
                  new InkWell(
                    onTap: (){
                      saveNewOrder(cart);
                    },
                    child: new Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 20.0,right: 20.0),
                      height: 50.0,
                      margin: EdgeInsets.only(top: 5.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.topRight,
                              colors: [
                                Colors.cyan,
                                Colors.indigo,
                              ]
                          )
                      ),
                      child: Center( child:  new Text(
                        'Complete Order',
                        softWrap: true,
                        style: new TextStyle(
                          fontSize: 15.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.start,
                      ),)
                    ),),
                ],
            ),
    ),

    );
  }
}
