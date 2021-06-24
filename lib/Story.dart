import 'dart:collection';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/AddressAddPage.dart';
import 'package:flutter_app/auth/Authentication.dart';
import 'package:flutter_app/model/CheckIn.dart';
import 'package:flutter_app/model/MenuItem.dart';
import 'package:flutter_app/model/Order.dart';
import 'package:flutter_app/model/User.dart';
import 'package:flutter_app/utils/TopWaveClipper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gender_selection/gender_selection.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/Address.dart';
import 'model/Constants.dart';

class Story extends StatefulWidget {
  Story({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _StoryState createState() => new _StoryState();
}

var cardAspectRatio = 12.0 / 16.0;
var widgetAspectRatio = cardAspectRatio * 1.2;
 List<CheckIn> checkInList = [];
List<Order> orders = [];


class _StoryState extends State<Story> with SingleTickerProviderStateMixin {
  var currentPage =  checkInList.length - 1.0;
  var orderCurrentPage =  orders.length - 1.0;
  PageController controller;
  PageController _orderController;
  TabController tabController;
  Auth auth = new Auth();
  firebaseAuth.User firebaseUser;
  User user;
  String _name;
  String _email;
  String _mobile;
  String _password;
  String _address;

  Future<void> getLocation() async {
    try {

      PermissionStatus permission = await LocationPermissions().requestPermissions();
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((position){
          _getAddress(position.latitude,position.longitude);
      });
    } on Exception catch (e) {
      print('Could not get location: ${e.toString()}');
    }
  }
  Future<void> _getAddress(double latitude,double longitude) async {
    List<Placemark> newPlace = await placemarkFromCoordinates(latitude,longitude);
    Placemark placeMark  = newPlace[0];
    setState(() {
      _address = placeMark.locality +","+placeMark.subLocality +","+placeMark.subThoroughfare; // update _address
    });
  }
  @override
  void initState() {
    super.initState();

    tabController = TabController(vsync: this, length: 3)..addListener((){
      setState(() {
        switch(tabController.index){
          case 0:
            getStory();
            break;
          case 1:
            getOrders();
            break;
          case 2:
            getUser();
            getLocation();
            break;
        }
      });
    });
  }
  getStory() async{
    firebaseUser = await auth.getCurrentUser();
    DatabaseReference postsReference = FirebaseDatabase.instance.reference().child("Users").child(firebaseUser.uid).child("Checkin");
    postsReference.keepSynced(true);
    await  postsReference.once().then((DataSnapshot snapshot){
        this.setState(() {
          checkInList.clear();
          var DATA = snapshot.value;
          if(DATA != null) {
            var KEYS = snapshot.value.keys;
            for (var individualKey in KEYS) {
              CheckIn checkIn = new CheckIn(
                  DATA[individualKey]['imageUrl'], DATA[individualKey]['name'],
                  DATA[individualKey]['shots'], DATA[individualKey]['date']);
              checkInList.add(checkIn);
            }
          }
          WidgetsBinding.instance.addPostFrameCallback((_) => {
            if(controller.hasClients){
                controller.animateToPage(
                  checkInList.length,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                )
              }
          }
          );
        });
    });
  }
  getOrders() async{
    firebaseUser = await auth.getCurrentUser();
    DatabaseReference clientsReference  = FirebaseDatabase.instance.reference().child("Users").child(firebaseUser.uid).child("orders");
    clientsReference.keepSynced(true);
    await  clientsReference.once().then((DataSnapshot snapshot){
      this.setState(() {
        orders.clear();
        var DATA = snapshot.value;
        if(DATA != null) {
          var KEYS = snapshot.value.keys;
          for (var individualKey in KEYS) {
            List<MenuItem> menuItems = [];
            var items = DATA[individualKey]['items'];
              if(items != null){
                for(int i = 0; i < DATA[individualKey]['items'].length; i++){
                  Map map = DATA[individualKey]['items'].elementAt(i);
                  // MenuItem menuItem = new MenuItem(map['image'], map['title'], map['details'], map['price'], map['size'], map['category'],map['quantity'],map['specialInstructions']);
                  // menuItems.add(menuItem);
                }
              }

            Order order = new Order(
                DATA[individualKey]['clientName'], DATA[individualKey]['orderNumber'],
                DATA[individualKey]['date'], menuItems, double.parse(DATA[individualKey]['total']),  double.parse(DATA[individualKey]['subTotal']),
                double.parse(DATA[individualKey]['fee']),DATA[individualKey]['orderType'],DATA[individualKey]['paymentMethod'],DATA[individualKey]['deliveryAddressUUID']
            );
                orders.add(order);
          }
        }
        WidgetsBinding.instance.addPostFrameCallback((_) =>{
        if(_orderController.hasClients){
          _orderController.animateToPage(
            orders.length,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          )
        }}
        );
      });
      getUser();
    });
  }
  getUser() async{
    Query userReference  = FirebaseDatabase.instance.reference().child("Users").child(firebaseUser.uid);
    await  userReference.once().then((DataSnapshot snapshot){
      this.setState(() {
            Map data = snapshot.value;
            MapEntry first = data.entries.first;
            Map address = first.value['Addresses'];
            Map<String,Address> addressMap = new Map();
            address.forEach((key, value) {
              Address address = new Address();
              addressMap.putIfAbsent(key, () => address);
            });
            addressMap.remove(null);
            setState(() {
              user = new User(firebaseUser.uid,   first.value["name"],   first.value["email"],    first.value["password"],   first.value["cellNumber"],addressMap);
              _name = user.name;
              _email = user.email;
              _mobile = user.cellNumber;
              _password = user.password;
            });

      });
    });
  }
  ListTile generateTiles(MenuItem item){
    return ListTile(
      title:Text(item.name,style: TextStyle(fontSize: 14),textAlign: TextAlign.start,),
      subtitle: Text('x'+item.quantity.toString(),style: TextStyle(fontSize: 11)),
    );
  }
  List<DataRow> generateData(Order order) {
    List<MenuItem> items = order.items;
    List<DataCell> cells = new List<DataCell>();
    List<DataRow> rows = new List<DataRow>();
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
            "R"+order.subTotal.toString(),
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
            "R"+order.fee.toString(),
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
          padding: EdgeInsets.only(right: 20,bottom: 10),
          child: new Text(
            "R"+order.total.toString(),
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

  Widget generateAccountDetails() {
    String validatePassword(String value){
      String  pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
      RegExp regExp = new RegExp(pattern);
      if (!regExp.hasMatch(value))
        return 'Password too weak';
      else
        return null;
    }
    String validateEmail(String value) {
      Pattern pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = new RegExp(pattern);
      if (!regex.hasMatch(value))
        return 'Enter Valid Email';
      else
        return null;
    }
   return new Card(
        elevation: 15.0,
        margin:EdgeInsets.all(10.0),
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(15),
       ),
        child: new Container(
            padding: new EdgeInsets.all(15.0),
            child: new Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(5),
                  child:TextFormField(
                    initialValue: _email,
                    obscureText: false,
                    style: TextStyle(fontFamily: 'Montserrat', fontSize: 13.0),
                    keyboardType: TextInputType.emailAddress,
                    validator: validateEmail,
                    onSaved: (String value) {
                      _email = value;
                    },
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        hintText: "Email",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                  ),//emailField,
                ),
                Padding(
                    padding: EdgeInsets.all(5),
                    child:TextFormField(
                      initialValue: _password,
                      obscureText: true,
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 13.0),
                      keyboardType: TextInputType.text,
                      validator: validatePassword ,
                      onSaved: (String value) {
                        _password = value;
                      },
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          hintText: "Password",
                          border:
                          OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                    )// passwordField,
                ),
                Padding(
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: <Widget>[
                        Checkbox(
                          activeColor: Colors.lightGreen,
                          value: user != null ? firebaseUser.emailVerified : false,
                          onChanged: null,
                        ),
                        Text("Email Varified",style: TextStyle(fontSize: 15.0,color:Colors.black87),),
                      ],
                    )
                ),
              ],
            )
        )
    );
  }
  Widget generatePersonalDetails(){
    String validateName(String value) {
      if (value.length < 3)
        return 'Name must be more than 2 charater';
      else
        return null;
    }

    String validateMobile(String value) {
      if (value.length != 10)
        return 'Mobile Number must be of 10 digit';
      else
        return null;
    }

   return new Card(
        elevation: 15.0,
        margin:EdgeInsets.all(10.0),
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(15),
       ),
        child: new Container(
            padding: new EdgeInsets.all(15.0),
            child: new Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(5),
                  child:TextFormField(
                    initialValue: _name,
                    obscureText: false,
                    style: TextStyle(fontFamily: 'Montserrat', fontSize: 13.0),
                    keyboardType: TextInputType.text,
                    validator: validateName,
                    onSaved: (String value) {
                      _name = value;
                    },
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        hintText: "Name & Surname",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                  ),//nameField,
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child:TextFormField(
                    initialValue: _mobile,
                    obscureText: false,
                    style: TextStyle(fontFamily: 'Montserrat', fontSize: 13.0),
                    keyboardType: TextInputType.phone,
                    inputFormatters:<TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly
                    ] ,
                    validator: validateMobile,
                    onSaved: (String value) {
                      _mobile = value;
                    },
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        hintText: "Cell Number",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                  ),//cellField
                ),
                GenderSelection(
                  selectedGenderIconBackgroundColor: Colors.transparent, // default red
                  checkIconAlignment: Alignment.center,
                  onChanged: (Gender gender){
                    print(gender);
                  },
                  linearGradient: LinearGradient(
                    colors: orangeGradients,
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight
                  ),
                  equallyAligned: true,
                  animationDuration: Duration(milliseconds: 400),
                  opacityOfGradient: 0.0,
                  unSelectedGenderTextStyle: TextStyle(fontSize: 18,color: Colors.black87),
                  padding: const EdgeInsets.all(3),
                  femaleImage: Image.asset("assets/images/venus.png",height: 50,width: 50,fit: BoxFit.cover).image,
                  maleImage: Image.asset("assets/images/mase.png",height: 30,width: 30,fit: BoxFit.cover).image,
                  size: 30, //default : 120

                ),
              ],)
        ));
  }
  Widget generateAddressDetails() {
    return new Card(
        elevation: 15.0,
        margin:EdgeInsets.all(10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: new Container(
            padding: new EdgeInsets.all(15.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
               user != null && user.addresses != null ? Padding(
                    padding: EdgeInsets.all(5),
                    child:new ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: user.addresses.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return new Container(
                            child : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Wrap(
                                      runSpacing: 4.0, // gap between lines
                                        direction: Axis.horizontal,
                                      children: <Widget>[
                                        Icon(Icons.location_on),
                                        Text(user.addresses.values.elementAt(index).nickName,style: TextStyle(
                                          fontSize: 16.0,),
                                        ),
                                      ]),
                                    IconButton(
                                      icon: Icon(
                                      Icons.remove_circle_outline,),
                                      iconSize: 25,
                                      color: Colors.redAccent,
                                      splashColor: Colors.blueAccent,
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Removing Address?'),
                                                content: Text('This will delete the selected address from your profile.'),
                                                actions: [
                                                  FlatButton(
                                                    textColor: Colors.redAccent,
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('CANCEL'),
                                                  ),
                                                  FlatButton(
                                                    textColor: Colors.greenAccent,
                                                    onPressed: () {
                                                      String key = user.addresses.keys.elementAt(index);
                                                      DatabaseReference reference  = FirebaseDatabase.instance.reference().child("Users").child(user.userID).reference();
                                                      reference.child("Addresses").child(key).remove().then((value) => {
                                                        Fluttertoast.showToast(msg: "Address has been removed",toastLength: Toast.LENGTH_SHORT),
                                                        Navigator.pop(context),
                                                      });
                                                    },
                                                    child: Text('ACCEPT'),
                                                  ),
                                                ],
                                              );
                                            });
                                      },)
                                  ],
                                ),
                                  Padding(
                                  padding: EdgeInsets.all(5),
                                    child: Text(user.addresses.values.elementAt(index).getFullAddress()),
                                  )
                              ],
                            )
                          );
                        }
                    )
                ) : new Container(
                 child: Center(
                   child: Text("No Addresses found. Add new"),
                 ),
               ),
              ],
            )
        )
    );
  }
  Widget generateLocation(){
    return new Card(
        elevation: 15.0,
        margin:EdgeInsets.all(10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: new Container(
            padding: new EdgeInsets.all(15.0),
            child: new Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(5),
                  child:TextFormField(
                    initialValue: _address,
                    obscureText: false,
                    enabled: false,
                    style: TextStyle(fontFamily: 'Montserrat', fontSize: 10.0),
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        hintText: "Location",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                  ),//nameField,
                ),
              ],)
        ));
  }
  @override
  Widget build(BuildContext context) {
    controller = PageController(initialPage: checkInList.length);
    controller.addListener(() {
      if(controller.hasClients){
        setState(() {
          currentPage = controller.page;
        });
      }
    });
    _orderController = PageController(initialPage: orders.length);
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
          padding: EdgeInsets.only(top: 12),),
      bottom: TabBar(
        tabs: <Widget>[
          Tab(child: Text("Check in's",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.0,
                fontFamily: "Calibre-Semibold",
              )),),
          Tab(child: Text("Orders",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.0,
                fontFamily: "Calibre-Semibold",
              )),),
          Tab(child: Text("Personal",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.0,
                fontFamily: "Calibre-Semibold",
              )),)
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
            preferredSize: Size.fromHeight(80.0),
            child: topAppBar,
          ),
          body: TabBarView(
            controller: tabController,
            children: <Widget>[
              SingleChildScrollView(
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
                                child: Text(checkInList.fold(0, (curr,next) => curr + int.parse(next.shots)).toString()+" shot's",
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
                                child: Text("3 Bottles",
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
                                                  title: Text(checkInList[index].name),
                                                ),
                                                ListTile(
                                                  leading: ImageIcon(new AssetImage("assets/images/shot-glass.png"),color: Color(0xFF03A0FE),size: 20.0,),
                                                  title: Text(checkInList[index].shots.toString()),
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
              ),
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0,top: 20.0),
                      child: Row(
                        children: <Widget>[
                          Container(
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
                                child: Text(orders.length.toString()+" Orders's",
                                    style: TextStyle(color: Colors.white,fontSize: 10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      children: <Widget>[
                        OrderCardScrollWidget(orderCurrentPage),
                        Positioned.fill(
                          child: PageView.builder(
                            itemCount: orders.length,
                            controller: _orderController,
                            reverse: true,
                            itemBuilder: (context, index) {
                              return Container(
                                  child: GestureDetector(onTap: (){
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
              ),
              SingleChildScrollView(
             child : Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: <Widget>[
                 Container(
                   width: 150,
                   margin: EdgeInsets.only(top: 15,left: 10),
                   decoration: BoxDecoration(
                     gradient:LinearGradient(
                         colors: orangeGradients,
                         begin: Alignment.topLeft,
                         end: Alignment.center),
                     borderRadius: BorderRadius.circular(20.0),
                   ),
                     child: Padding(
                       padding: EdgeInsets.symmetric(
                           horizontal: 20.0, vertical: 6.0),
                       child: Text("Personal Details",
                           style: TextStyle(color: Colors.white,fontSize: 13)),
                     ),
                 ),
                    generatePersonalDetails(),
                     Container(
                       width: 150,
                       margin: EdgeInsets.only(top: 5,left: 10),
                       decoration: BoxDecoration(
                         gradient:LinearGradient(
                             colors: blueGradients,
                             begin: Alignment.topLeft,
                             end: Alignment.center),
                         borderRadius: BorderRadius.circular(20.0),
                       ),
                         child: Padding(
                           padding: EdgeInsets.symmetric(
                               horizontal: 22.0, vertical: 6.0),
                           child: Text("Account Details",
                               style: TextStyle(color: Colors.white,fontSize: 13)),
                         ),
                     ),
                 generateAccountDetails(),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: <Widget>[
                     Container(
                       width: 150,
                       margin: EdgeInsets.only(top: 5,left: 10),
                       decoration: BoxDecoration(
                         gradient:LinearGradient(
                             colors: orangeGradients,
                             begin: Alignment.topLeft,
                             end: Alignment.center),
                         borderRadius: BorderRadius.circular(20.0),
                       ),
                       child: Padding(
                         padding: EdgeInsets.symmetric(
                             horizontal: 22.0, vertical: 6.0),
                         child: Text("Addresses",
                             style: TextStyle(color: Colors.white,fontSize: 13)),
                       ),
                     ),
                     Center(
                         child:IconButton(icon: Icon(
                           Icons.add_circle_outline,
                         ),
                           iconSize: 30,
                           color: Colors.green,
                           splashColor: Colors.blueAccent,
                           onPressed: () {
                             Navigator.push(
                               context,
                               MaterialPageRoute(builder: (context) => AddressAddPage(title: "Add New Address",user: user,)),
                             );
                           },)
                     )
                   ],
                 ),
                generateAddressDetails(),
               ],)
              )
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
  var padding = 20.0;
  var verticalInset = 20.0;

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
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(3.0, 6.0),
                      blurRadius: 10.0)
                ]),
                child: AspectRatio(
                  aspectRatio: cardAspectRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
//                      Image.network(checkInList[i].image, fit: BoxFit.cover),
                      CachedNetworkImage(imageUrl: checkInList[i].image,fit:BoxFit.cover ,fadeInDuration: Duration(milliseconds: 1000),),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Text(checkInList[i].name,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25.0,
                                      fontFamily: "SF-Pro-Text-Regular")),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),

                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 12.0, bottom: 12.0),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 22.0, vertical: 6.0),
                                decoration: BoxDecoration(
                                    gradient:LinearGradient(
                                        colors: TopWaveClipper.orangeGradients,
                                        begin: Alignment.topLeft,
                                        end: Alignment.center),
                                    borderRadius: BorderRadius.circular(20.0)),
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
  var padding = 20.0;
  var verticalInset = 20.0;

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
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(3.0, 6.0),
                      blurRadius: 10.0)
                ]),
                child: AspectRatio(
                  aspectRatio: cardAspectRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                     CachedNetworkImage(imageUrl: orders[i].items[0].image,fit:BoxFit.cover ,fadeInDuration: Duration(milliseconds: 1000),),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Text(orders[i].clientName,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25.0,
                                      fontFamily: "SF-Pro-Text-Regular")),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Text(orders[i].orderNumber,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontFamily: "SF-Pro-Text-Regular")),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 12.0, bottom: 12.0),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 22.0, vertical: 6.0),
                                decoration: BoxDecoration(
                                    gradient:LinearGradient(
                                        colors: TopWaveClipper.orangeGradients,
                                        begin: Alignment.topLeft,
                                        end: Alignment.center),
                                    borderRadius: BorderRadius.circular(20.0)),
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