import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/auth/Authentication.dart';
import 'package:flutter_app/menu/OrderTracking.dart';
import 'package:flutter_app/model/Client.dart';
import 'package:flutter_app/model/MenuItem.dart';
import 'package:flutter_app/model/NotificationDTO.dart' as dto;
import 'package:flutter_app/model/Order.dart';
import 'package:flutter_app/model/OrderItem.dart';
import 'package:flutter_app/model/User.dart';
import 'package:flutter_app/service/AddressService.dart';
import 'package:flutter_app/service/ClientService.dart';
import 'package:flutter_app/service/NotificationService.dart';
import 'package:flutter_app/service/OrderService.dart';
import 'package:flutter_app/service/UserService.dart';
import 'package:flutter_app/utils/TopWaveClipper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:page_transition/page_transition.dart';
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
  UserService userService = new UserService();
  OrderService orderService = new OrderService();
  AddressService addressService = new AddressService();
  ClientService clientService = new ClientService();
  NotificationService notificationService = new NotificationService();
  User _user;
  Client _client;
  ProgressDialog progressDialog;

  List<Row> generateOrderTotals(OrderCart cart) {
    List<Row> rows = new List<Row>();
    itemTotal = 0.0;
    fee = 30.0;
    total = 0.0;
    for (var item in cart.cart) {
      itemTotal += item.menuItem.price;
    }
    total = itemTotal + fee;
    rows.add(new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 10.sp, bottom: 10.sp, top: 10.sp),
          child: new Text(
            'Subtotal',
            softWrap: true,
            style: new TextStyle(
                fontSize: 13.0.sp,
                color: Colors.black87,
                fontWeight: FontWeight.normal),
            textAlign: TextAlign.end,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 10.sp, bottom: 10.sp),
          child: new Text(
            "R" + '$itemTotal',
            softWrap: true,
            style: new TextStyle(
                fontSize: 13.0.sp,
                color: Colors.black87,
                fontWeight: FontWeight.normal),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    ));
    rows.add(new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 10.sp, bottom: 10.sp),
          child: new Text(
            'Service fee',
            softWrap: true,
            style: new TextStyle(
                fontSize: 13.0.sp,
                color: Colors.black87,
                fontWeight: FontWeight.normal),
            textAlign: TextAlign.end,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 10.sp, bottom: 10.sp),
          child: new Text(
            "R" + '$fee',
            softWrap: true,
            style: new TextStyle(
                fontSize: 13.0.sp,
                color: Colors.black87,
                fontWeight: FontWeight.normal),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    ));
    rows.add(new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 10.sp, bottom: 10.sp),
          child: new Text(
            'Total',
            softWrap: true,
            style: new TextStyle(
                fontSize: 13.0.sp,
                color: Colors.black87,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.end,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 10.sp),
          child: new Text(
            "R" + '$total',
            softWrap: true,
            style: new TextStyle(
                fontSize: 13.0.sp,
                color: Colors.black87,
                fontWeight: FontWeight.bold),
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
  }

  Future<User> getUser() async {
    String userKey = await auth.getCurrentUser();
    _user = await userService.fetchByKey(userKey);
    return _user;
  }


  saveNewOrder(OrderCart cart) async {
    progressDialog.show();
    String userKey = await auth.getCurrentUser();
    Order order = new Order.from(
        userKey: userKey,
        clientKey: cart.clientKey,
        addressKey: cart.address.key,
        fee: fee,
        subTotal: itemTotal,
        total: total,
        orderItems: cart.cart);
      if(cart.orderTypeMethod.contains("Collection")){
        order.collection = true;
        order.delivery = false;
      }else{
        order.collection = false;
        order.delivery = true;
      }

     String orderKey = await orderService.save(order);
      if(orderKey != null && orderKey.isNotEmpty){
        Order freshOrder = await orderService.fetchByKey(orderKey);

        dto.Notification notification = new dto.Notification();
        notification.userType = 'CLIENT';
        notification.title = "New Order";
        notification.message = "New order placed "+ freshOrder.orderNumber;
        notification.userKey = order.clientKey;
        await notificationService.send(notification);

        freshOrder.address = cart.address;
        cart.clearAll();
        progressDialog.hide();
        Navigator.pushAndRemoveUntil(
          context,
          PageTransition(type: PageTransitionType.rightToLeft, child: OrderTracker(order: freshOrder,willPop: false,)),
              (route) => false,
        );
      }


  }

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<OrderCart>(context);
    final topAppBar = NewGradientAppBar(
      elevation: 0.1.sp,
      gradient: LinearGradient(colors: [Colors.cyan, Colors.indigo]),
      title: Text("Order Summary"),
    );
    progressDialog = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: true, showLogs: false);
    progressDialog.style(
        message: 'Submitting Order',
        borderRadius: 10.0.sp,
        backgroundColor: Colors.white,
        progressWidget: SpinKitCubeGrid(
          color: Color(0xffff5722),
          size: 25.0.sp,
        ),
        elevation: 10.0.sp,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 11.0.sp,
            fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18.0.sp,
            fontWeight: FontWeight.w600));

    getClient()async{
      _client = await clientService.fetchByKey(cart.clientKey);
      setState(() {});
    }
    getClient();
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: topAppBar,
        body:Center(
      child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: FutureBuilder(
              future: getUser(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Card(
                            elevation: 10.0.sp,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Container(
                                      width: 65.0.sp,
                                      height: 65.0.sp,
                                      margin: EdgeInsets.all(8.0.sp),
                                      decoration: new BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: new DecorationImage(
                                          fit: BoxFit.cover,
                                          image: CachedNetworkImageProvider(_client.profileUrl),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left:5.sp,bottom: 10.sp, top: 10.sp),
                                      child: new Text(
                                        _client != null
                                            ? _client.name.trim()
                                            : '',
                                        softWrap: true,
                                        style: new TextStyle(
                                            fontSize: 16.0.sp,
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left:10.0.sp,top: 5.sp,bottom: 10.sp),
                                  child: new Text(
                                    _user != null
                                        ? "Contact Number : " +
                                        _client.cellNumber.trim()
                                        : '',
                                    softWrap: true,
                                    style: new TextStyle(
                                      fontSize: 14.0.sp,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Card(
                            elevation: 10.0.sp,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left:5.sp,bottom: 10.sp, top: 10.sp),
                                  child: new Text(
                                    'How we will contact you',
                                    softWrap: true,
                                    style: new TextStyle(
                                        fontSize: 15.0.sp,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10.sp),
                                  child: new Text(
                                    _user != null
                                        ? "Name : " + _user.name.trim()
                                        : '',
                                    softWrap: true,
                                    style: new TextStyle(
                                      fontSize: 14.0.sp,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left:10.0.sp,top: 5.sp,bottom: 10.sp),
                                  child: new Text(
                                    _user != null
                                        ? "Contact Number : " +
                                        _user.cellNumber.trim()
                                        : '',
                                    softWrap: true,
                                    style: new TextStyle(
                                      fontSize: 14.0.sp,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Card(
                            elevation: 10.0.sp,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 10.sp,
                                      top: 5.sp),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      new Text(
                                        'Address Details',
                                        softWrap: true,
                                        style: new TextStyle(
                                            fontSize: 15.0.sp,
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.start,
                                      ),
                                      new InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: new Container(
                                            height: 30.0.sp,
                                            width: 80.sp,
                                            margin: EdgeInsets.only(
                                                top: 10.0.sp,
                                                right: 10.0.sp),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0.sp)),
                                                gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.topRight,
                                                    colors: TopWaveClipper
                                                        .orangeGradients)),
                                            child: Center(
                                              child: new Text(
                                                'Change',
                                                softWrap: true,
                                                style: new TextStyle(
                                                  fontSize: 11.0.sp,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.start,
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                                ListTile(
                                  title: Text('${cart.address.nickName}'),
                                  subtitle:Text('${cart.address.houseNumber} ${cart.address.streetName} ${cart.address.suburb} ${cart.address.city}  ${cart.address.province} ${cart.address.code}') ,
                                ),
                              ],
                            ),
                          ),
                        ),

                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: new Card(
                            elevation: 10.0.sp,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 10.sp,
                                          top: 20.sp),
                                      child: new Text(
                                        'Item(s)',
                                        softWrap: true,
                                        style: new TextStyle(
                                            fontSize: 15.0.sp,
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                    DataTable(
                                      sortAscending: true,
                                      columnSpacing: 60.0.sp,
                                      dataRowHeight: 65.0.sp,
                                      columns: <DataColumn>[
                                        DataColumn(label: Text(' ')),
                                        DataColumn(label: Text('Item')),
                                        DataColumn(label: Text('Price')),
                                      ],
                                      rows: generateData(cart),
                                    ),
                                    Column(
                                      children: generateOrderTotals(cart),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 10.sp,
                                      bottom: 10.sp,
                                      top: 20.sp),
                                  child: new Text(
                                    'Available Payment Options',
                                    softWrap: true,
                                    style: new TextStyle(
                                        fontSize: 15.0.sp,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 10.0),
                                  child: Center(
                                    child: ToggleSwitch(
                                      totalSwitches: 2,
                                      minHeight: 35.sp,
                                      minWidth: 150.sp,
                                      cornerRadius: 5.0.sp,
                                      activeBgColor: [Colors.blue],
                                      activeFgColor: Colors.white,
                                      inactiveBgColor: Colors.blue,
                                      inactiveFgColor: Colors.white,
                                      labels: ['Cash', 'Speed Point'],
                                      iconSize: 12.sp,
                                      icons: [
                                        FontAwesomeIcons.moneyBillWave,
                                        FontAwesomeIcons.creditCard,
                                      ],
                                      onToggle: (index) {
                                        print("index" + index.toString());
                                        switch (index) {
                                          case 0:
                                            setState(() {
                                              paymentMethod = 'Cash';
                                            });
                                            break;
                                          case 1:
                                            setState(() {
                                              paymentMethod = 'Speed Point';
                                            });
                                            break;
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        new InkWell(
                            onTap: () {
                              saveNewOrder(cart);
                            },
                            child: new Container(
                                height: 50.0.sp,
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.all(10.0.sp),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(5.0.sp)),
                                    gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.topRight,
                                        colors: TopWaveClipper
                                            .orangeGradients)),
                                child: Center(
                                  child: new Text(
                                    'Check out',
                                    softWrap: true,
                                    style: new TextStyle(
                                      fontSize: 15.0.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                )),
                          ),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                } else {
                  return Center(
                    child: SpinKitCubeGrid(color: Color(0xffff5722)),
                  );
                }
              })))
    );
  }

  ListTile generateTiles(MenuItem item) {
    return ListTile(
      title: Text(
        item.name,
        style: TextStyle(fontSize: 14.sp),
        textAlign: TextAlign.start,
      ),
      subtitle: Text('x' + item.quantity.toString(),
          style: TextStyle(fontSize: 11.sp)),
    );
  }

  List<DataRow> generateData(OrderCart bloc) {
    List<OrderItem> items = bloc.cart;
    List<DataCell> cells = [];
    List<DataRow> rows = [];
    for (var item in items) {
      DataCell imageCell = DataCell(new Image(
        height: 50.0.sp,
        fit: BoxFit.contain,
        image: CachedNetworkImageProvider(item.menuItem.image),
      ));
      DataCell nameCell = DataCell(generateTiles(item.menuItem));
      DataCell priceCell = DataCell(Padding(
        padding: EdgeInsets.only(left: 12.0.sp),
        child: Text('R' + item.menuItem.price.toString()),
      ));

      cells.add(imageCell);
      cells.add(nameCell);
      cells.add(priceCell);

      List<DataCell> cells1 = [];
      cells1.addAll(cells);
      rows.add(DataRow(cells: cells1));
      cells.clear();
    }
    return rows;
  }
}
