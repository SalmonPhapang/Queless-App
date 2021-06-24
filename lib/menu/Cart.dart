import 'dart:core';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Story.dart';
import 'package:flutter_app/auth/Authentication.dart';
import 'package:flutter_app/menu/OrderSummary.dart';
import 'package:flutter_app/menu/OrderTracking.dart';
import 'package:flutter_app/model/Constants.dart';
import 'package:flutter_app/model/MenuItem.dart';
import 'package:flutter_app/model/Order.dart';
import 'package:flutter_app/utils/TopWaveClipper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

import 'OrderCart.dart';

class CartPage extends StatefulWidget {
  CartPage({Key key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();

}
class _CartPageState extends State<CartPage> {

  double itemTotal = 0.0;
  double fee = 30.0;
  double total = 0.0;
  Auth auth = new Auth();
  ProgressDialog progressDialog;
  @override
  void initState() {
    super.initState();
  }
  ListTile generateTiles(MenuItem item){
    return ListTile(
      title:Text(item.name,style: TextStyle(fontSize: 14),textAlign: TextAlign.start,),
      subtitle: Text('x'+item.quantity.toString(),style: TextStyle(fontSize: 11)),
    );
  }
  List<DataRow> generateData(OrderCart bloc) {
    List<MenuItem> items = bloc.cart;
    List<DataCell> cells = new List<DataCell>();
    List<DataRow> rows = new List<DataRow>();
    for(var item in items) {
      DataCell imageCell = DataCell(new Image(
        height: 50.0,
        fit: BoxFit.contain,
        image: CachedNetworkImageProvider(item.image),
      ));
      DataCell nameCell = DataCell(generateTiles(item));
      DataCell priceCell = DataCell(Text('R'+item.price.toString()));
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
              padding: const EdgeInsets.all(5.0),
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                gradient:LinearGradient(
                    colors: TopWaveClipper.orangeGradients,
                    begin: Alignment.topLeft,
                    end: Alignment.center),
              ),
              child: new Icon(Icons.close, size: 12.0, color: Colors.white)),
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
          padding: EdgeInsets.only(left: 10,bottom: 10),
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
          padding: EdgeInsets.only(left: 10),
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
  Widget build(BuildContext context) {
    var bloc = Provider.of<OrderCart>(context);
    final topAppBar = NewGradientAppBar(
      elevation: 0.1,
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
                    margin: EdgeInsets.only(top: 10),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(50.0)),
                      color: Colors.white,
                    ),
                    child: Stack(children: <Widget>[
                      new Column(
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(top: 30.0),
                              child :  ConstrainedBox(
                                constraints: BoxConstraints(maxHeight: 420 , minHeight: 200),
                                child: ListView(
                                  shrinkWrap: true,
                                  children: <Widget>[
                                    new Text(
                                      "Cart Items",
                                      softWrap: true,
                                      style: new TextStyle(
                                          fontSize: 20.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: new DataTable(
                                        sortAscending: true,
                                        columnSpacing: 20.0,
                                        dataRowHeight: 65.0,
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
                                padding: EdgeInsets.only(bottom: 5),
                                child: new Text(
                                  "Estimated preparation time +- 20 min",
                                  softWrap: true,
                                  style: new TextStyle(
                                      fontSize: 11.0,
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
                                      MaterialPageRoute(builder: (context) => OrderSummary()),
                                    );
                                  },
                                  child: new Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 40.0,
                                    padding: EdgeInsets.only(top: 14),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(50.0),topRight: Radius.circular(50.0)),
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
                                      'Place Order',
                                      softWrap: true,
                                      style: new TextStyle(
                                          fontSize: 19.0,
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