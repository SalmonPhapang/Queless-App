import 'dart:core';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/menu/OrderCart.dart';
import 'package:flutter_app/model/MenuItem.dart';
import 'package:flutter_app/utils/TopWaveClipper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:provider/provider.dart';

class MenuDetailsPage extends StatefulWidget {
  MenuDetailsPage({Key key,this.item}) : super(key: key);

  final MenuItem item;

  @override
  _MenuDetailsPageState createState() => _MenuDetailsPageState();

}
class _MenuDetailsPageState extends State<MenuDetailsPage> {
  int quantity = 1;
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var bloc = Provider.of<OrderCart>(context);
    final instructionsField = TextField(
      maxLines: 2,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Special Instrictions",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );// passwordField
    final topAppBar = NewGradientAppBar(
      elevation: 0.1,
      gradient: LinearGradient(colors: [Colors.cyan,Colors.indigo]),
      title: Text(widget.item.name),
      actions: <Widget>[
    new Center(
        child: Padding(
        padding: EdgeInsets.only(right:10.0),
        child: Text(
          "R"+widget.item.price.toString(),
          style: new TextStyle(
              fontSize: 15.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto'
          )
        ),
        ),
    )],
    );
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: topAppBar,
        body: new Container(
          alignment: Alignment.topCenter,
          child: new Card(
            elevation: 15.0,
            margin:EdgeInsets.all(10.0),
            child: new Column(
              crossAxisAlignment:CrossAxisAlignment.start ,
              mainAxisSize : MainAxisSize.min,
              children: <Widget>[
                widget.item.image != null ||  widget.item.image != "" ?  Stack(
                  children: <Widget>[
                    Center(
                      child: CachedNetworkImage(imageUrl: widget.item.image,fit:BoxFit.cover,height: 280 ,fadeInDuration: Duration(milliseconds: 1000),),
                    ),
                  ],
                ) : Center(child: Image.asset('assets/loader2.gif',height:280.0,fit: BoxFit.fitWidth,)),
                Padding(
                    padding: EdgeInsets.only(top:20.0,left: 10.0,right: 10.0,bottom: 20.0),
                    child: Text(
                        widget.item.description,
                        style: new TextStyle(
                            fontSize: 15.0,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'Roboto'
                        )
                    )
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(top:20.0,left: 10.0,right: 10.0,bottom: 20.0),
                        child: Text(
                            "R"+widget.item.price.toString(),
                            style: new TextStyle(
                                fontSize: 15.0,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto'
                            )
                        )
                    ),
                    Padding(
                        padding: EdgeInsets.only(top:20.0,left: 10.0,right: 10.0,bottom: 20.0),
                        child: Text(
                            widget.item.quantity.toString()+" x "+widget.item.size.toString(),
                            style: new TextStyle(
                                fontSize: 15.0,
                                color: Colors.black87,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Roboto'
                            )
                        )
                    ),
                ],),

            Padding(
              padding: EdgeInsets.only(left: 10.0,right: 10.0,bottom: 10.0),
              child: instructionsField,
            ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new InkWell(
                      onTap: () =>
                          this.setState((){
                            if(quantity != 0){
                              quantity--;
                            }
                          }
                          ),
                      child: new Container(
                          padding: const EdgeInsets.all(5.0),
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            gradient:LinearGradient(
                                colors: TopWaveClipper.orangeGradients,
                                begin: Alignment.topLeft,
                                end: Alignment.center),
                          ),
                          child: new Icon(Icons.remove, size: 13.0, color: Colors.white)),
                    ),//............,
                    SizedBox(width: 20,),
                    Text('$quantity',
                        style: new TextStyle(
                            fontSize: 15.0,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto'
                        )
                    ),
                    SizedBox(width: 20,),
                    new InkWell(
                      onTap: () =>
                          this.setState(() => {
                            quantity++
                          }),
                      child: new Container(
                          padding: const EdgeInsets.all(5.0),
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            gradient:LinearGradient(
                                colors: TopWaveClipper.orangeGradients,
                                begin: Alignment.topLeft,
                                end: Alignment.center),
                          ),
                          child: new Icon(Icons.add, size: 13.0, color: Colors.white)),
                    ),//............
                  ],
                ),
            Padding(
              padding: EdgeInsets.only(top: 20.0,bottom: 20.0),
              child: Center(
                  child: RaisedButton(
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(18.0),
                    ),
                    elevation: 10.0,
                    onPressed: () {
                      if(bloc.addToCart(widget.item)) {
                        widget.item.quantity = quantity;
                       // bloc.setClientName(widget.clientName);
                        Fluttertoast.showToast(msg: "Item(s) added to order",
                            toastLength: Toast.LENGTH_SHORT,
                            textColor: Colors.white);
                        Navigator.pop(context);
                      }else{
                        Fluttertoast.showToast(msg: "Cannot order duplicate items ",
                            toastLength: Toast.LENGTH_SHORT,
                            textColor: Colors.white);
                      }
                    },
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: Text("Add To Cart".toUpperCase(),
                        style: TextStyle(fontSize: 14)),
                  ),
                )
            )

              ],//Column Children
            )//Column,
        ),
        )
    );
  }
}