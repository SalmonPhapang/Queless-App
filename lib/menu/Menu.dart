import 'dart:core';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/menu/Cart.dart';
import 'package:flutter_app/menu/MenuDetails.dart';
import 'package:flutter_app/menu/OrderCart.dart';
import 'package:flutter_app/model/MenuItem.dart';
import 'package:flutter_app/service/MenuItemService.dart';
import 'package:flutter_app/utils/TopWaveClipper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:badges/badges.dart';
import 'package:provider/provider.dart';
import "package:collection/collection.dart";
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MenuPage extends StatefulWidget {
  MenuPage({Key key, this.title, this.clientKey}) : super(key: key);

  final String title;
  final String clientKey;

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {
  List<MenuItem> menus = [];
  List<String> categories = [];
  Map<String, List<MenuItem>> drinksMenu;
  Map<String, List<MenuItem>> menu;
  TabController tabController;

  MenuItemService _menuItemService = new MenuItemService();

  @override
  void initState() {
    super.initState();
    findMenu();
    tabController = TabController(vsync: this, length: 2);
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
      gradient: LinearGradient(colors: [Colors.cyan, Colors.indigo]),
      title: Text(widget.title),
      actions: <Widget>[
        new Center(
          child: Padding(
            padding: EdgeInsets.only(right: 20.0.sp, top: 10.sp),
            child: Badge(
              badgeContent: Text(
                bloc.cart.length.toString(),
                style: TextStyle(color: Colors.white),
              ),
              toAnimate: true,
              padding: EdgeInsets.all(8.sp),
              badgeColor: Colors.deepOrange,
              child: IconButton(
                icon: Icon(Icons.shopping_cart,
                    size: 20.0.sp, color: Colors.white),
                onPressed: () {
                  if (totalCount > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartPage()),
                    );
                  } else {
                    Fluttertoast.showToast(
                        msg: "Nothing in the Cart",
                        toastLength: Toast.LENGTH_SHORT);
                  }
                },
              ),
            ),
          ),
        )
      ],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: topAppBar,
      body: Center(
          child: FutureBuilder(
        future: findMenu(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return new CustomScrollView(
                slivers: this
                    .menu
                    .entries
                    .map((e) => SliverStickyHeader.builder(
                          builder: (context, state) => Container(
                            height: 40.0.sp,
                            color: Colors.white
                                .withOpacity(1.0 - state.scrollPercentage),
                            padding: EdgeInsets.symmetric(horizontal: 16.0.sp),
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
                        ))
                    .toList());
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          } else {
            return SpinKitCubeGrid(color: Color(0xffff5722));
          }
        },
      )),
    );
  }

  Future<Map<String, List<MenuItem>>> findMenu() async {
    menus = await _menuItemService.fetchByClient(widget.clientKey);
    this.menu = groupBy(menus, (item) => item.categoryType);
    // List<MenuItem> drinksMenu = menus.where((element) => element.inventoryType.contains("DRINKS")).toList();
    // this.drinksMenu = groupBy(drinksMenu, (item) => item.categoryType);
    return this.menu;
  }

  Widget MenuUI(MenuItem menuItem) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MenuDetailsPage(item: menuItem)));
          },
          child: new Card(
            elevation: 3.0.sp,
            margin: EdgeInsets.all(5.0.sp),
            child: new Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      top: 5.0.sp, left: 10.0.sp, bottom: 5.0.sp),
                  child: new Image(
                    height: 100.sp,
                    width: MediaQuery.of(context).size.width / 2,
                    fit: BoxFit.contain,
                    image: CachedNetworkImageProvider(menuItem.image),
                  ),
                ),
                new Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: 5.0.sp, left: 10.0.sp, bottom: 10.0.sp),
                        child: new Text(
                          menuItem.name,
                          style: new TextStyle(
                              fontSize: 13.0.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 10.0.sp, bottom: 10.0.sp),
                        child: new Text(
                          menuItem.quantity.toString() +
                              ' x ' +
                              menuItem.size.toString(),
                          softWrap: true,
                          style: new TextStyle(
                              fontSize: 10.0.sp,
                              color: Colors.grey[750],
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Text(
                              'R' + menuItem.price.toString(),
                              softWrap: true,
                              style: new TextStyle(
                                  fontSize: 11.0.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,),
                              textAlign: TextAlign.start,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: TopWaveClipper.orangeGradients,
                                    begin: Alignment.topLeft,
                                    end: Alignment.center),
                                borderRadius: BorderRadius.circular(20.0.sp),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 22.0.sp, vertical: 6.0.sp),
                                  child: Text("More",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.sp)),
                                ),
                              ),
                            ),
                          ]),
                    ])),
              ],
            ), //Row
          ),
        ),
        Visibility(
          visible: !menuItem.available,
          child: Container(
            height: 110.sp,
            width: MediaQuery.of(context)
                .size
                .width,
            color: Colors.black.withOpacity(0.5.sp),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_off,
                  color: Colors.white,
                  size: 30.sp,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0.sp),
                  child: Text(
                    'Unavailable',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
