import 'dart:core';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/menu/Cart.dart';
import 'package:flutter_app/menu/MenuDetails.dart';
import 'package:flutter_app/menu/OrderCart.dart';
import 'package:flutter_app/model/MenuItem.dart';
import 'package:flutter_app/model/MenuList.dart';
import 'package:flutter_app/service/MenuItemService.dart';
import 'package:flutter_app/utils/TopWaveClipper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:badges/badges.dart';
import 'package:provider/provider.dart';
import "package:collection/collection.dart";
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
class MenuPage extends StatefulWidget {
  MenuPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<MenuItem> menus = [];
  Map<String,List<MenuItem>> groupedmenu;

  MenuItemService _menuItemService = new MenuItemService();
  @override
  void initState() {
    super.initState();
    findMenu();
  }
  @override
  Widget build(BuildContext context) {
    var bloc = Provider.of<OrderCart>(context);
    int totalCount = 0;
    if (bloc.cart.length > 0) {
      totalCount = bloc.cart.length;
    }
    ScrollController _controller = new ScrollController();
    final topAppBar = NewGradientAppBar(
      elevation: 0.1,
      gradient: LinearGradient(colors: [Colors.cyan,Colors.indigo]),
      title: Text(widget.title),
      actions: <Widget>[
        new Center(
          child: Padding(
            padding: EdgeInsets.only(right:20.0,top: 10),
            child: Badge(
              badgeContent: Text('$totalCount',style: TextStyle(color: Colors.white),),
              toAnimate: true,
              padding: EdgeInsets.all(8),
              badgeColor: Colors.deepOrange,
              child: IconButton(
                  icon: Icon(Icons.shopping_cart, size: 20.0, color: Colors.white),
                  onPressed:(){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartPage()),
                    );
                  } ,
              ),
            ),
          ),
        )
      ],
    );

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: topAppBar,
        body:Center(child: FutureBuilder(
          future: findMenu(),
          builder: (context,snapshot){
            if(snapshot.hasData){
            return  new CustomScrollView(
                  slivers: groupedmenu.entries.map((e) =>
                    SliverStickyHeader.builder(
                      builder: (context, state) => Container(
                        height: 40.0,
                        color: Colors.white.withOpacity(1.0 - state.scrollPercentage),
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          e.key,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, i) => MenuUI(e.value[i]),
                          childCount: e.value.length,
                        ),
                      ),
                    )).toList());


            }else if(snapshot.hasError){
              return Text("${snapshot.error}");
            }else{
              return SpinKitCubeGrid(color: Color(0xffff5722));
            }
          },
        )

    ));
  }

  Future<Map<String,List<MenuItem>>> findMenu() async{
    menus = await _menuItemService.fetchAll();
    groupedmenu = groupBy(menus, (item) => item.categoryType);
    print(groupedmenu.keys.toList());
    return groupedmenu;
  }

  Widget MenuUI(MenuItem menuItem){

   return new InkWell(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => MenuDetailsPage(item: menuItem)));

        },
      child: new Card(
     elevation: 3.0,
     margin:EdgeInsets.all(5.0),
     child: new Row(
             children: <Widget>[
               Padding(
                 padding: EdgeInsets.only(top: 5,left:10.0,bottom: 5.0),
                 child: new Image(
                   height: 100,
                   width: MediaQuery.of(context).size.width/2,
                   fit: BoxFit.contain,
                   image: CachedNetworkImageProvider(menuItem.image),
                 ),
               ),
               new Expanded(child: Column(
                   crossAxisAlignment:CrossAxisAlignment.start ,
                   children: <Widget>[
                     Padding(
                       padding: EdgeInsets.only(top: 5,left:10.0,bottom: 10.0),
                       child: new Text(
                         menuItem.name,
                         style: new TextStyle(
                             fontSize: 12.0,
                             color: Colors.black,
                             fontWeight: FontWeight.bold,
                             fontFamily: 'Roboto'
                         ),
                         textAlign: TextAlign.start,
                       ),
                     ),

                     Padding(
                       padding: EdgeInsets.only(left: 10.0,bottom: 10.0),
                       child: new Text(
                         menuItem.quantity.toString() +' x '+menuItem.size.toString(),
                         softWrap: true,
                         style: new TextStyle(
                             fontSize: 10.0,
                             color: Colors.grey[750],
                             fontWeight: FontWeight.normal,
                             fontFamily: 'Roboto'
                         ),
                         textAlign: TextAlign.start,
                       ),
                     ),
                     new Row(
                         mainAxisAlignment: MainAxisAlignment.spaceAround,
                         children: <Widget>[
                           Text(
                             'R'+menuItem.price.toString(),
                             softWrap: true,
                             style: new TextStyle(
                                 fontSize: 12.0,
                                 color: Colors.black,
                                 fontWeight: FontWeight.bold,
                                 fontFamily: 'Roboto'
                             ),
                             textAlign: TextAlign.start,
                           ),
                           Container(
                             decoration: BoxDecoration(
                               gradient:LinearGradient(
                                   colors: TopWaveClipper.orangeGradients,
                                   begin: Alignment.topLeft,
                                   end: Alignment.center),
                               borderRadius: BorderRadius.circular(20.0),
                             ),
                             child: Center(
                               child: Padding(
                                 padding: EdgeInsets.symmetric(
                                     horizontal: 22.0, vertical: 6.0),
                                 child: Text("More",
                                     style: TextStyle(color: Colors.white,fontSize: 10)),
                               ),
                             ),
                           ),
                         ]),

                   ]))

               ,
             ],
           ),//Row
     ),
    );

  }
}