import 'dart:core';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Story.dart';
import 'package:flutter_app/auth/Authentication.dart';
import 'package:flutter_app/menu/AddressPage.dart';
import 'package:flutter_app/menu/OrderSummary.dart';
import 'package:flutter_app/menu/OrderTracking.dart';
import 'package:flutter_app/model/Constants.dart';
import 'package:flutter_app/model/MenuItem.dart';
import 'package:flutter_app/model/Order.dart';
import 'package:flutter_app/model/OrderItem.dart';
import 'package:flutter_app/utils/TopWaveClipper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:page_transition/page_transition.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

import 'OrderCart.dart';

class CartPage extends StatefulWidget {
  CartPage({Key key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();

}
class _CartPageState extends State<CartPage> {

  Auth auth = new Auth();
  ProgressDialog progressDialog;
  @override
  void initState() {
    super.initState();
  }
  ListTile generateTiles(MenuItem item,int quantity){
    return ListTile(
      title:Text(item.name,style: TextStyle(fontSize: 14.sp),textAlign: TextAlign.start,),
      subtitle: Text('x'+quantity.toString(),style: TextStyle(fontSize: 11.sp)),
    );
  }
  List<DataRow> generateData(OrderCart bloc) {
    List<OrderItem> items = bloc.cart;
    List<DataCell> cells = new List<DataCell>();
    List<DataRow> rows = new List<DataRow>();
    for(var item in items) {
      DataCell imageCell = DataCell(new Image(
        height: 50.0.sp,
        fit: BoxFit.contain,
        image: CachedNetworkImageProvider(item.menuItem.image),
      ));
      DataCell nameCell = DataCell(generateTiles(item.menuItem,item.quantity));
      DataCell priceCell = DataCell(Text('R'+item.menuItem.price.toString()));
      DataCell removeCell = DataCell(
        new InkWell(
          onTap: () => {
          this.setState((){
              Fluttertoast.showToast(msg: "item(s) removed");
              bloc.clear(item);
              if(bloc.cart.length == 0){
                Navigator.pop(context);
              }
            })
          },
          child: new Container(
              padding:  EdgeInsets.all(5.0.sp),
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                gradient:LinearGradient(
                    colors: TopWaveClipper.orangeGradients,
                    begin: Alignment.topLeft,
                    end: Alignment.center),
              ),
              child: new Icon(Icons.close, size: 12.0.sp, color: Colors.white)),
        ),
      );
      cells.add(imageCell);
      cells.add(nameCell);
      cells.add(priceCell);
      cells.add(removeCell);

      List<DataCell> cells1 = new List<DataCell>();
      cells1.addAll(cells);
      rows.add(DataRow(cells:cells1));
      cells.clear();
    }
    return rows;
  }

  List<Row> generateOrderTotals(OrderCart cart){
    List<Row> rows = new List<Row>();
   rows.add(new Row(
     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 10.sp,bottom: 10.sp),
          child: new Text(
            'Subtotal',
            softWrap: true,
            style: new TextStyle(
                fontSize: 13.0.sp,
                color: Colors.black87,
                fontWeight: FontWeight.normal
            ),
            textAlign: TextAlign.end,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 20.sp,bottom: 10.sp),
          child: new Text(
            "R"+cart.subTotal.toString(),
            softWrap: true,
            style: new TextStyle(
                fontSize: 13.0.sp,
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
          padding: EdgeInsets.only(left: 10.sp,bottom: 10.sp),
          child: new Text(
            'Delivery fee',
            softWrap: true,
            style: new TextStyle(
                fontSize: 13.0.sp,
                color: Colors.black87,
                fontWeight: FontWeight.normal
            ),
            textAlign: TextAlign.end,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 20.sp,bottom: 10.sp),
          child: new Text(
            "R"+cart.fee.toString(),
            softWrap: true,
            style: new TextStyle(
                fontSize: 13.0.sp,
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
          padding: EdgeInsets.only(left: 10.sp),
          child: new Text(
            'Total',
            softWrap: true,
            style: new TextStyle(
                fontSize: 13.0.sp,
                color: Colors.black87,
                fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.end,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 20.sp),
          child: new Text(
            "R"+cart.total.toString(),
            softWrap: true,
            style: new TextStyle(
                fontSize: 13.0.sp,
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
  Widget build(BuildContext context) {
    var bloc = Provider.of<OrderCart>(context);
    final topAppBar = NewGradientAppBar(
      elevation: 0.1.sp,
      gradient: LinearGradient(colors: [Colors.cyan,Colors.indigo]),
      title: Text("Your Cart"),
    );

    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: topAppBar,
        body: new Stack(
          children: <Widget>[
            new Container(
              width : MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [
                        Colors.cyan,
                        Colors.indigo,
                      ]
                  )
              ),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                 new Container(
                    margin: EdgeInsets.only(top: 10.sp),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 100.sp,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(50.0.sp)),
                      color: Colors.white,
                    ),
                    child: Stack(children: <Widget>[
                      new Column(
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(top: 30.0.sp),
                              child :  ConstrainedBox(
                                constraints: BoxConstraints(maxHeight: 420.sp , minHeight: 200.sp),
                                child: ListView(
                                  shrinkWrap: true,
                                  children: <Widget>[
                                    new Text(
                                      "Cart Items",
                                      softWrap: true,
                                      style: new TextStyle(
                                          fontSize: 20.0.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: new DataTable(
                                        sortAscending: true,
                                        columnSpacing: 20.0.sp,
                                        dataRowHeight: 65.0.sp,
                                        columns: <DataColumn>[
                                          DataColumn(label: Text(' ')),
                                          DataColumn(label: Text('Item') ),
                                          DataColumn(label: Text('Price')),
                                          DataColumn(label: Text(' ')),
                                        ] ,
                                        rows: generateData(bloc),
                                      ),
                                    )
                                  ],
                                ),
                              )
                          ),
                        ],
                      ),
                      Positioned(
                          bottom: 0.0,
                          child: Column(
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child:Column(children: generateOrderTotals(bloc),),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 5.sp),
                                child: new Text(
                                  "Estimated preparation time +- 20 min",
                                  softWrap: true,
                                  style: new TextStyle(
                                      fontSize: 11.0.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.normal
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: new InkWell(
                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      PageTransition(type: PageTransitionType.rightToLeft, child:AddressPage(title: "Select Address",)),
                                    );
                                  },
                                  child: new Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 40.0.sp,
                                    padding: EdgeInsets.only(top: 14.sp),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(50.0.sp),topRight: Radius.circular(50.0.sp)),
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.topRight,
                                            colors: [
                                              Colors.cyan,
                                              Colors.indigo,
                                            ]
                                        )
                                    ),
                                    child: new Text(
                                      'Order',
                                      softWrap: true,
                                      style: new TextStyle(
                                          fontSize: 19.0.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),),
                              ),
                            ],
                          )
                      ),
                    ],)
                  ),
                ],
              ),
            ),

          ],
        ),

    );
  }
}