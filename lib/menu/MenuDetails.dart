import 'dart:core';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/menu/OrderCart.dart';
import 'package:flutter_app/model/MenuItem.dart';
import 'package:flutter_app/utils/TopWaveClipper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          contentPadding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
          hintText: "Special Instrictions",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(10.0.sp))),
    );// passwordField
    final topAppBar = NewGradientAppBar(
      elevation: 0.1.sp,
      gradient: LinearGradient(colors: [Colors.cyan,Colors.indigo]),
      title: Text(widget.item.name),
      actions: <Widget>[
    new Center(
        child: Padding(
        padding: EdgeInsets.only(right:10.0.sp),
        child: Text(
          "R"+widget.item.price.toString(),
          style: new TextStyle(
              fontSize: 15.0.sp,
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
        body: SingleChildScrollView(
          child: new Container(
          alignment: Alignment.topCenter,
          child: new Card(
            elevation: 15.0.sp,
            margin:EdgeInsets.all(10.0.sp),
            child: new Column(
              crossAxisAlignment:CrossAxisAlignment.start ,
              mainAxisSize : MainAxisSize.min,
              children: <Widget>[
                widget.item.image != null ||  widget.item.image != "" ?  Stack(
                  children: <Widget>[
                    Center(
                      child: CachedNetworkImage(imageUrl: widget.item.image,fit:BoxFit.cover,height: 150.sp ,fadeInDuration: Duration(milliseconds: 1000),),
                    ),
                  ],
                ) : Center(child: Image.asset('assets/loader2.gif',height:280.0.sp,fit: BoxFit.fitWidth,)),
                Padding(
                    padding: EdgeInsets.only(top:10.0.sp,left: 10.0.sp,right: 10.0.sp,bottom: 10.0.sp),
                    child: Text(
                        widget.item.description,
                        style: new TextStyle(
                            fontSize: 15.0.sp,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal,
                        )
                    )
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(top:15.0.sp,left: 10.0.sp,right: 10.0.sp,bottom: 10.0.sp),
                        child: Text(
                            "R"+widget.item.price.toString(),
                            style: new TextStyle(
                                fontSize: 12.0.sp,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                            )
                        )
                    ),
                    Padding(
                        padding: EdgeInsets.only(top:15.0.sp,left: 10.0.sp,right: 10.0.sp,bottom: 10.0.sp),
                        child: Text(
                            widget.item.quantity.toString()+" x "+widget.item.size.toString(),
                            style: new TextStyle(
                                fontSize: 12.0.sp,
                                color: Colors.black87,
                                fontWeight: FontWeight.normal,
                            )
                        )
                    ),
                ],),

            Padding(
              padding: EdgeInsets.only(left: 10.0.sp,right: 10.0.sp,bottom: 20.0.sp),
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
                          padding:  EdgeInsets.all(5.0.sp),
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            gradient:LinearGradient(
                                colors: TopWaveClipper.orangeGradients,
                                begin: Alignment.topLeft,
                                end: Alignment.center),
                          ),
                          child: new Icon(Icons.remove, size: 13.0.sp, color: Colors.white)),
                    ),//............,
                    SizedBox(width: 20,),
                    Text('$quantity',
                        style: new TextStyle(
                            fontSize: 15.0.sp,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                        )
                    ),
                    SizedBox(width: 20.sp,),
                    new InkWell(
                      onTap: () =>
                          this.setState(() => {
                            quantity++
                          }),
                      child: new Container(
                          padding:  EdgeInsets.all(5.0.sp),
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            gradient:LinearGradient(
                                colors: TopWaveClipper.orangeGradients,
                                begin: Alignment.topLeft,
                                end: Alignment.center),
                          ),
                          child: new Icon(Icons.add, size: 13.0.sp, color: Colors.white)),
                    ),//............
                  ],
                ),

                Container(
                  width: MediaQuery.of(context).size.width.sp,
                  margin: EdgeInsets.only(top:20.0.sp,left: 5.0.sp,right: 5.0.sp,bottom: 20.0.sp),
                  height: 40.0.sp,
                  child:  FlatButton(
                    onPressed: (){
                      if(bloc.clientKey == null || bloc.clientKey.contains(widget.item.clientKey)){
                        bloc.setClientKey(widget.item.clientKey);
                        if(bloc.addToCart(widget.item,quantity)) {
                          Fluttertoast.showToast(msg: "Item(s) added to order",
                              toastLength: Toast.LENGTH_SHORT,
                              textColor: Colors.white);
                          Navigator.pop(context);
                        }else{
                          Fluttertoast.showToast(msg: "Cannot order duplicate items ",
                              toastLength: Toast.LENGTH_SHORT,
                              textColor: Colors.white);
                        }
                      }else{
                        Fluttertoast.showToast(msg: "Cannot order from multiple restaurants",
                            toastLength: Toast.LENGTH_SHORT,
                            textColor: Colors.white);
                      }
                    },
                    child: new Text(
                      "Add To Cart",
                      style: new TextStyle(
                          fontSize: 15.0.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                    ),
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(10.0.sp),
                        side: BorderSide(color: Colors.blue)
                    ),
                  ),
                ),
              ],//Column Children
            )//Column,
        ),
        ))
    );
  }
}