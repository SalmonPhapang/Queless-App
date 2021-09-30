import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:flutter/material.dart';
import 'package:flutter_app/auth/Authentication.dart';
import 'package:flutter_app/menu/OrderTracking.dart';
import 'package:flutter_app/model/CheckIn.dart';
import 'package:flutter_app/model/MenuItem.dart';
import 'package:flutter_app/model/Order.dart';
import 'package:flutter_app/model/User.dart';
import 'package:flutter_app/profile/SettingsPage.dart';
import 'package:flutter_app/service/AddressService.dart';
import 'package:flutter_app/service/FeedService.dart';
import 'package:flutter_app/service/MenuItemService.dart';
import 'package:flutter_app/service/OrderService.dart';
import 'package:flutter_app/service/UserService.dart';
import 'package:flutter_app/utils/TopWaveClipper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:math';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';
import 'model/Feed.dart';
import 'service/CheckInService.dart';

class Story extends StatefulWidget {
  Story({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _StoryState createState() => new _StoryState();
}

var cardAspectRatio = 12.0.sp / 16.0.sp;
var widgetAspectRatio = cardAspectRatio * 1.2.sp;
 List<CheckIn> checkInList = [];
List<Order> orders = [];

class _StoryState extends State<Story> with SingleTickerProviderStateMixin {
  var currentPage =  0.0;
  var orderCurrentPage =  0.0;
  PageController controller;
  PageController _orderController;
  TabController tabController;
  Auth auth = new Auth();
  CheckInService checkInService = new CheckInService();
  OrderService orderService = new OrderService();
  AddressService addressService = new AddressService();
  UserService userService = new UserService();
  MenuItemService menuItemService = new MenuItemService();
  FeedService feedService = new  FeedService();
  firebaseAuth.User firebaseUser;
  User user;
  bool isLoadingCheckin = true;
  bool isLoadingOrder = true;
  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 2);
    getCheckIn();
    getOrders();
  }
  Future<List> getCheckIn() async{
    String userKey = await auth.getCurrentUser();
    checkInList = await checkInService.fetchByUser(userKey);
    for(var checkIn in checkInList){
      checkIn.feed = await feedService.fetchByKey(checkIn.feedKey);
    }

      WidgetsBinding.instance.addPostFrameCallback((_) => {
        if(controller.hasClients){
          controller.animateToPage(
            checkInList.length,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          )
        }
      });
    setState(() {
      isLoadingCheckin = false;
    });
  }
  Future<List> getOrders() async{
    String userKey = await auth.getCurrentUser();
    orders = await orderService.fetchByUser(userKey);
    for(var order in orders) {
      order.address = await addressService.fetchByKey(order.addressKey);
      for(var orderItem in order.orderItems) {
        orderItem.menuItem = await menuItemService.fetchByKey(orderItem.menuItemKey);
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => {
      if(_orderController.hasClients){
        _orderController.animateToPage(
          orders.length,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        )
      }}
    );
    setState(() {
      orderCurrentPage = orders.length - 1.0;
      isLoadingOrder  = false;
    });
    return orders;
  }
  ListTile generateTiles(MenuItem item){
    return ListTile(
      title:Text(item.name,style: TextStyle(fontSize: 14.sp),textAlign: TextAlign.start,),
      subtitle: Text('x'+item.quantity.toString(),style: TextStyle(fontSize: 11.sp)),
    );
  }
  List<DataRow> generateData(Order order) {
    List<MenuItem> items = [];
    List<DataCell> cells = new List<DataCell>();
    List<DataRow> rows = new List<DataRow>();
    for(var orderItem in order.orderItems) {
      items.add(orderItem.menuItem);
    }
    for(var item in items) {
      DataCell nameCell = DataCell(generateTiles(item));
      DataCell priceCell = DataCell(Text('R'+item.price.toString()));
      cells.add(nameCell);
      cells.add(priceCell);

      List<DataCell> cells1 = new List<DataCell>();
      cells1.addAll(cells);
      rows.add(DataRow(cells:cells1));
      cells.clear();
    }
    return rows;
  }
  List<Row> generateOrderTotals(Order order){
    List<Row> rows = new List<Row>();
    rows.add(new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 10.sp,bottom: 10.sp),
          child: new Text(
            'Type',
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
            order.delivery ? "Delivery":"Collection",
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
            'Status',
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
            order.orderStatus,
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
            "R"+order.subTotal.toString(),
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
            'Service fee',
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
            "R"+order.fee.toString(),
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
          padding: EdgeInsets.only(right: 20.sp,bottom: 10.sp),
          child: new Text(
            "R"+order.total.toString(),
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
    controller = PageController(initialPage: 0);
    controller.addListener(() {
      if(controller.hasClients){
        setState(() {
          currentPage = controller.page;
        });
      }
    });
    _orderController = PageController(initialPage: 0);
    _orderController.addListener(() {
      if(_orderController.hasClients){
        setState(() {
          orderCurrentPage = _orderController.page;
        });
      }
    });
    final topAppBar = NewGradientAppBar(
      elevation: 0.1,
      gradient: LinearGradient(colors: [Colors.cyan,Colors.indigo]),
      title: Padding(
          child: Text(widget.title,),
          padding: EdgeInsets.only(top: 12.sp),),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.settings,
            color: Colors.white,
            size: 20.0.sp,
          ),
          onPressed: () {
            Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: SettingsPage(title: "Settings",)),);
          },
        )
      ],
      bottom: TabBar(
        tabs: <Widget>[
          Tab(child: Text("Check in's",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.0.sp,
                fontFamily: "Calibre-Semibold",
              )),),
          Tab(child: Text("Orders",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.0.sp,
                fontFamily: "Calibre-Semibold",
              )),),
        ],
        indicatorColor:Colors.white ,
        controller: tabController,
      ),
    );

    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  Color(0xFF1b1e44),
                  Color(0xFF2d3447),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                tileMode: TileMode.clamp)),
        child: Scaffold(
          backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(80.0.sp),
            child: topAppBar,
          ),
          body: TabBarView(
            controller: tabController,
            children: <Widget>[
             checkInList.length != 0 ? SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0,top: 20.0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              gradient:LinearGradient(
                                  colors: orangeGradients,
                                  begin: Alignment.topLeft,
                                  end: Alignment.center),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 22.0, vertical: 6.0),
                                child: Text(checkInList.length.toString()+" TurnUp's",
                                    style: TextStyle(color: Colors.white,fontSize: 10)),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 5.0),
                            decoration: BoxDecoration(
                              gradient:LinearGradient(
                                  colors: blueGradients,
                                  begin: Alignment.topLeft,
                                  end: Alignment.center),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 22.0, vertical: 6.0),
                                child: Text(checkInList.fold(0, (curr,next) => curr + int.parse(next.feed.shots)).toString()+" shot's",
                                    style: TextStyle(color: Colors.white,fontSize: 10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      children: <Widget>[
                        CardScrollWidget(currentPage),
                        Positioned.fill(
                          child: PageView.builder(
                            itemCount: checkInList.length,
                            controller: controller,
                            reverse: true,
                            itemBuilder: (context, index) {
                              return Container(
                                  child: GestureDetector(onTap: (){
                                    showModalBottomSheet(context: context, builder: (builder) {
                                      return new Container(
                                        height: 200.0,
                                        color: Color(0xFF1b1e44), //could change this to Color(0xFF737373),
                                        //so you don't have to change MaterialApp canvasColor
                                        child: new Container(
                                            decoration: new BoxDecoration(
                                                color: Theme.of(context).canvasColor,
                                                borderRadius: new BorderRadius.only(
                                                    topLeft: const Radius.circular(10.0),
                                                    topRight: const Radius.circular(10.0))),
                                            child:new Column(
                                              children: <Widget>[
                                                Container(
                                                    margin: EdgeInsets.only(top: 10.0),
                                                    child: Center(
                                                      child: Text("Details",style: TextStyle(fontSize: 17.0,fontWeight: FontWeight.bold,color: Color(0xFFFE8853),fontFamily: "san-serif-medium")),
                                                    )
                                                ),
                                                ListTile(
                                                  leading: Icon(Icons.place,color : Color(0xFFFE8853)),
                                                  title: Text(checkInList[index].feed.title),
                                                ),
                                                ListTile(
                                                  leading: ImageIcon(new AssetImage("assets/images/shot-glass.png"),color: Color(0xFF03A0FE),size: 20.0,),
                                                  title: Text(checkInList[index].feed.shots.toString()),
                                                ),
                                                ListTile(
                                                  leading: Icon(Icons.calendar_today,color: Color(0xFF0EDED2)),
                                                  title: Text(checkInList[index].date),
                                                )
                                              ],
                                            )

                                        ),
                                      );
                                    });
                                  },));
                            },
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                  ],
                ),
              ): !isLoadingCheckin ? Center(child:Text("Nothing Yet!",style: TextStyle(color: Colors.white,fontSize: 25.0.sp),) ,):SpinKitCubeGrid(color: Color(0xffff5722)),
             orders.length != 0 ? SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0,top: 20.0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              gradient:LinearGradient(
                                  colors: orangeGradients,
                                  begin: Alignment.topLeft,
                                  end: Alignment.center),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 22.0, vertical: 6.0),
                                child: Text(orders.length.toString()+" Orders's",
                                    style: TextStyle(color: Colors.white,fontSize: 10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),  Stack(
                            children: <Widget>[
                              OrderCardScrollWidget(orderCurrentPage),
                              Positioned.fill(
                                  child: PageView.builder(
                                    itemCount: orders.length,
                                    controller: _orderController,
                                    reverse: true,
                                    itemBuilder: (context, index) {
                                      return Container(
                                          child: GestureDetector(
                                            onTap: (){
                                            showModalBottomSheet(context: context, builder: (builder) {
                                              return new Container(
                                                color: Color(0xFF1b1e44),
                                                child: new Container(
                                                    decoration: new BoxDecoration(
                                                        color: Theme.of(context).canvasColor,
                                                        borderRadius: new BorderRadius.only(
                                                            topLeft: const Radius.circular(10.0),
                                                            topRight: const Radius.circular(10.0))),
                                                    child:new Column(
                                                      children: <Widget>[
                                                        Container(
                                                            margin: EdgeInsets.only(top: 10.0),
                                                            child: Center(
                                                              child: Text("Details",style: TextStyle(fontSize: 17.0,fontWeight: FontWeight.bold,color: Color(0xFFFE8853),fontFamily: "san-serif-medium")),
                                                            )
                                                        ),
                                                        Expanded(
                                                          child: ListView(
                                                            children: <Widget>[
                                                              SingleChildScrollView(
                                                                scrollDirection: Axis.vertical,
                                                                child: new DataTable(
                                                                  sortAscending: true,
                                                                  columnSpacing: 20.0,
                                                                  dataRowHeight: 65.0,
                                                                  columns: <DataColumn>[
                                                                    DataColumn(label: Text('Item') ),
                                                                    DataColumn(label: Text('Price')),
                                                                  ] ,
                                                                  rows: generateData(orders[index]),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        Column(
                                                            children :generateOrderTotals(orders[index])
                                                        ),
                                                        InkWell(
                                                            onTap: ()=>{
                                                              Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: OrderTracker(order: orders[index],willPop: true,)))
                                                            },
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(
                                                                  right: 10.0,left:10.0 , bottom: 10.0),
                                                              child: Container(
                                                                width: MediaQuery.of(context).size.width,
                                                                padding: EdgeInsets.symmetric(
                                                                    horizontal: 22.0, vertical: 6.0),
                                                                decoration: BoxDecoration(
                                                                    gradient:LinearGradient(
                                                                        colors: TopWaveClipper.blueGradients,
                                                                        begin: Alignment.topLeft,
                                                                        end: Alignment.center),
                                                                    borderRadius: BorderRadius.circular(20.0)),
                                                                child: Center(
                                                                  child: Text("Track Order",
                                                                    style: TextStyle(color: Colors.white)),),
                                                              ),
                                                            )
                                                        )
                                                      ],
                                                    )

                                                ),
                                              );
                                            });
                                          },));
                                    },
                                  )
                              )
                            ],
                          ),
                    SizedBox(
                      height: 20.0,
                    ),
                  ],
                ),
              ) : !isLoadingOrder ? Center(child:Text("Nothing Yet!",style: TextStyle(color: Colors.white,fontSize: 25.0.sp),) ,) : SpinKitCubeGrid(color: Color(0xffff5722)),
            ],
          )
        ),
      );
  }
  static List<Color> orangeGradients = [
    Color(0xFFFF9844),
    Color(0xFFFE8853),
    Color(0xFFFD7267),
  ];
  static List<Color> blueGradients = [
    Color(0xFF0EDED2),
    Color(0xFF03A0FE),
  ];
}

class CardScrollWidget extends StatelessWidget {
  var currentPage;
  var padding = 20.0.sp;
  var verticalInset = 20.0.sp;

  CardScrollWidget(this.currentPage);

  @override
  Widget build(BuildContext context) {
    return new AspectRatio(
      aspectRatio: widgetAspectRatio,
      child: LayoutBuilder(builder: (context, contraints) {
        var width = contraints.maxWidth;
        var height = contraints.maxHeight;

        var safeWidth = width - 2 * padding;
        var safeHeight = height - 2 * padding;

        var heightOfPrimaryCard = safeHeight;
        var widthOfPrimaryCard = heightOfPrimaryCard * cardAspectRatio;

        var primaryCardLeft = safeWidth - widthOfPrimaryCard;
        var horizontalInset = primaryCardLeft / 2;

        List<Widget> cardList = new List();

        for (var i = 0; i < checkInList.length; i++) {
          var delta = i - currentPage;
          bool isOnRight = delta > 0;

          var start = padding +
              max(
                  primaryCardLeft -
                      horizontalInset * -delta * (isOnRight ? 15 : 1),
                  0.0);

          var cardItem = Positioned.directional(
            top: padding + verticalInset * max(-delta, 0.0),
            bottom: padding + verticalInset * max(-delta, 0.0),
            start: start,
            textDirection: TextDirection.rtl,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0.sp),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(3.0.sp, 6.0.sp),
                      blurRadius: 10.0.sp)
                ]),
                child: AspectRatio(
                  aspectRatio: cardAspectRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
//                      Image.network(checkInList[i].image, fit: BoxFit.cover),
                      CachedNetworkImage(imageUrl: checkInList[i].feed.image,fit:BoxFit.cover ,fadeInDuration: Duration(milliseconds: 1000),),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0.sp, vertical: 8.0.sp),
                              child: Text(checkInList[i].feed.title,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25.0.sp,
                                      fontFamily: "SF-Pro-Text-Regular")),
                            ),
                            SizedBox(
                              height: 10.0.sp,
                            ),

                            Padding(
                              padding: EdgeInsets.only(
                                  left: 12.0.sp, bottom: 12.0.sp),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 22.0.sp, vertical: 6.0.sp),
                                decoration: BoxDecoration(
                                    gradient:LinearGradient(
                                        colors: TopWaveClipper.orangeGradients,
                                        begin: Alignment.topLeft,
                                        end: Alignment.center),
                                    borderRadius: BorderRadius.circular(20.0.sp)),
                                child: Text("Details",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
          cardList.add(cardItem);
        }
        return Stack(
          children: cardList,
        );
      }),
    );

  }

}
class OrderCardScrollWidget extends StatelessWidget {
  var currentPage;
  var padding = 20.0.sp;
  var verticalInset = 20.0.sp;
  OrderCardScrollWidget(this.currentPage);

  @override
  Widget build(BuildContext context) {
    return new AspectRatio(
      aspectRatio: widgetAspectRatio,
      child: LayoutBuilder(builder: (context, contraints) {
        var width = contraints.maxWidth;
        var height = contraints.maxHeight;

        var safeWidth = width - 2 * padding;
        var safeHeight = height - 2 * padding;

        var heightOfPrimaryCard = safeHeight;
        var widthOfPrimaryCard = heightOfPrimaryCard * cardAspectRatio;

        var primaryCardLeft = safeWidth - widthOfPrimaryCard;
        var horizontalInset = primaryCardLeft / 2;

        List<Widget> cardList = new List();

        for (var i = 0; i < orders.length; i++) {
          var delta = i - currentPage;
          bool isOnRight = delta > 0;

          var start = padding +
              max(
                  primaryCardLeft -
                      horizontalInset * -delta * (isOnRight ? 15 : 1),
                  0.0);

          var cardItem = Positioned.directional(
            top: padding + verticalInset * max(-delta, 0.0),
            bottom: padding + verticalInset * max(-delta, 0.0),
            start: start,
            textDirection: TextDirection.rtl,
            child:  ClipRRect(
              borderRadius: BorderRadius.circular(16.0.sp),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(3.0.sp, 6.0.sp),
                      blurRadius: 10.0.sp)
                ]),
                child: AspectRatio(
                  aspectRatio: cardAspectRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                     CachedNetworkImage(imageUrl: orders[i].orderItems[0].menuItem.image,fit:BoxFit.cover ,fadeInDuration: Duration(milliseconds: 1000),),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0.sp, vertical: 8.0.sp),
                              child: Text('#${orders[i].orderNumber}',
                                  style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 18.0.sp,
                                      fontFamily: "SF-Pro-Text-Regular")),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding:  EdgeInsets.only(
                                      left: 12.0.sp, bottom: 12.0.sp),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 22.0.sp, vertical: 6.0.sp),
                                    decoration: BoxDecoration(
                                        gradient:LinearGradient(
                                            colors: TopWaveClipper.orangeGradients,
                                            begin: Alignment.topLeft,
                                            end: Alignment.center),
                                        borderRadius: BorderRadius.circular(20.0.sp)),
                                    child: Text("Details",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ),

                              ],
                            )

                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
          cardList.add(cardItem);
        }
        return Stack(
          children: cardList,
        );
      }),
    );

  }

}