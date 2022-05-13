import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/auth/Authentication.dart';
import 'package:flutter_app/menu/Cart.dart';
import 'package:flutter_app/menu/Menu.dart';
import 'package:flutter_app/menu/OrderCart.dart';
import 'package:flutter_app/model/Client.dart';
import 'package:flutter_app/service/AddressService.dart';
import 'package:flutter_app/service/ClientService.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class ClientMenuPage extends StatefulWidget {
  ClientMenuPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ClientMenuPageState createState() => _ClientMenuPageState();
}

class _ClientMenuPageState extends State<ClientMenuPage> {
  ClientService clientService = new ClientService();
  AddressService addressService = new AddressService();
  Auth auth = new Auth();
  List<Client> clients = [];
  List<Client> clientsToFilter = [];
  Position _position;

 void getLocation() async {
    try {
      _position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high,);
      getClients();
    } on Exception catch (e) {
      print('Could not get location: ${e.toString()}');
    }
  }
  void getClients() async {
     clients = await clientService.fetchCanOrder();
     for(var client in clients){
       client.address =  await addressService.fetchByClientKey(client.key);
       calculateDistance(client);
     }
     clientsToFilter.addAll(clients);
     setState(() {});
  }
  int calculateDeliveryFee(int distance){
    if(distance <= 5){
      return 15;
    }else if(distance > 5 && distance <= 10){
      return 20;
    }else{
      return 30;
    }
  }
  calculateDistance(Client client) async{
    double distance =  await Geolocator.distanceBetween(_position.latitude, _position.longitude, double.parse(client.address.location.latitude), double.parse(client.address.location.longitude));
    clients.sort((a, b) {
      return a.distance !=null && b.distance !=null ? a.distance.compareTo(b.distance) : -1;
    });
    client.distance = distance / 1000.0;
  }

  @override
  void initState() {
    super.initState();
    getLocation();
  }
  FloatingSearchBarController _floatingSearchBarController = FloatingSearchBarController();
  @override
  Widget build(BuildContext context) {
    var bloc = Provider.of<OrderCart>(context);
    int totalCount = 0;
    if (bloc.cart.length > 0) {
      totalCount = bloc.cart.length;
    }
    final topAppBar = NewGradientAppBar(
      elevation: 0.1.sp,
      gradient: LinearGradient(colors: [Colors.cyan, Colors.indigo]),
      title: Text(widget.title),
      actions: <Widget>[
        new Center(
          child: Padding(
            padding: EdgeInsets.only(right:20.0.sp,top: 10.sp),
            child: Badge(
              badgeContent: Text(bloc.cart.length.toString(),style: TextStyle(color: Colors.white),),
              toAnimate: true,
              padding: EdgeInsets.all(8.sp),
              badgeColor: Colors.deepOrange,
              child: IconButton(
                icon: Icon(Icons.shopping_cart, size: 20.0.sp, color: Colors.white),
                onPressed:(){
                  if(totalCount > 0){
                    Navigator.push(
                      context, PageTransition(type: PageTransitionType.rightToLeft, child:CartPage()),
                    );
                  }else{
                    Fluttertoast.showToast(msg: "Nothing in the Cart",toastLength: Toast.LENGTH_SHORT);
                  }

                } ,
              ),
            ),
          ),
        )
      ],
    ); //AppBar

    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: topAppBar,
        body:  Stack(
            children:<Widget>[
              Padding(
                padding: EdgeInsets.only(top: 55.0.sp),
                child: clients.length != 0 ?
                ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: <Widget>[
                          new Card(
                            elevation: 5.0.sp,
                            shadowColor: Colors.grey[100],
                            child: new Container(
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Stack(
                                    alignment: Alignment.center,
                                    children: <Widget>[
                                      InkWell(
                                        onTap: () {
                                          if(clients[index].distance.round() > 30){
                                            Fluttertoast.showToast(msg: "Sorry cannot order from store, too far away",toastLength: Toast.LENGTH_LONG);
                                          }else{
                                            bloc.setDeliveryFee(calculateDeliveryFee(clients[index].distance.round()).toDouble());
                                            Navigator.push(
                                              context,
                                              PageTransition(type: PageTransitionType.rightToLeft, child:
                                              MenuPage(
                                                title: "Menu",
                                                clientKey:
                                                clients[index].key,
                                              )),
                                            );
                                          }
                                         
                                        },
                                        child: new Image(
                                          height: 200.sp,
                                          width: MediaQuery.of(context)
                                              .size
                                              .width,
                                          fit: BoxFit.cover,
                                          image: CachedNetworkImageProvider(
                                              clients[index].coverImage),
                                        ),
                                      ),
                                      Visibility(
                                        visible: !clients[index].online,
                                        child: Container(
                                          height: 200.sp,
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
                                                  'OFFLINE',
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
                                  ),
                                  new Row(
                                    children: <Widget>[
                                      Container(
                                        width: 40.0.sp,
                                        height: 40.0.sp,
                                        margin: EdgeInsets.all(5.0.sp),
                                        decoration: new BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: new DecorationImage(
                                            fit: BoxFit.cover,
                                            image:
                                            CachedNetworkImageProvider(
                                                clients[index]
                                                    .profileUrl),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(left: 5.0),
                                        constraints: new BoxConstraints(
                                            maxWidth: 150.sp),
                                        child: new Text(
                                          clients[index].name,
                                          style: new TextStyle(
                                              fontSize: 14.0.sp,
                                              color: Colors.black87,
                                              fontWeight:
                                              FontWeight.bold),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                      new Spacer(),
                                      Padding(
                                        padding: EdgeInsets.only(right:5.sp),
                                        child: Wrap(
                                            spacing: 10.sp,
                                            children: <Widget>[
                                              Column(
                                                children: <Widget>[
                                                  Container(
                                                    width: 30.sp,
                                                    height: 30.sp,
                                                    child:  CircleAvatar(
                                                      backgroundColor: Colors.orange,
                                                      radius: 30,
                                                      child: Icon(
                                                        Icons.accessibility,
                                                        color: Colors.white,
                                                        size: 20.sp,),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(top: 5.0),
                                                    child: new Container(
                                                        child: new Text(
                                                          "Collection",
                                                          style: new TextStyle(
                                                              fontSize: 8.0.sp,
                                                              color: Colors.black87,
                                                              fontWeight:
                                                              FontWeight.bold),
                                                          textAlign: TextAlign.start,
                                                        )),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                children: <Widget>[
                                                  Container(
                                                    width: 30.sp,
                                                    height: 30.sp,
                                                    child:  CircleAvatar(
                                                      backgroundColor: Colors.blue,
                                                      radius: 30,
                                                      child: Icon(
                                                        Icons.delivery_dining,
                                                        color: Colors.white,
                                                        size: 20.sp,),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(top: 5.0),
                                                    child: new Container(
                                                        child: new Text(
                                                          "Delivery",
                                                          style: new TextStyle(
                                                              fontSize: 8.0.sp,
                                                              color: Colors.black87,
                                                              fontWeight:
                                                              FontWeight.bold),
                                                          textAlign: TextAlign.start,
                                                        )),
                                                  ),
                                                ],
                                              )

                                            ]),
                                      ),
                                    ],
                                  ), //Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(left: 18.0.sp,bottom: 10.0.sp),
                                        child: Text(
                                            clients[index].distance != null ? clients[index].distance.round().toString()+" Km" : "",
                                          style: new TextStyle(
                                              fontSize: 10.0.sp,
                                              color: Colors.black54,
                                              fontWeight:
                                              FontWeight.bold),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(right: 10.0.sp,bottom: 10.0.sp),
                                        child: Text(
                                            clients[index].distance != null ? "Delivery fee R"+calculateDeliveryFee(clients[index].distance.round()).toString():"",
                                          style: new TextStyle(
                                              fontSize: 10.0.sp,
                                              color: Colors.black54,
                                              fontWeight:
                                              FontWeight.bold),
                                          textAlign: TextAlign.start,
                                        ),
                                      )
                                    ],
                                  )
                                ], //[Widget]
                              ), //Column
                            ), //Container
                          ), //Cards ,
                        ],
                      );
                    }) :
                Center(
                    child:SpinKitCubeGrid(color: Color(0xffff5722))),
              ),
              buildFloatingSearchBar(),
            ]
                ));
  }

  Widget buildFloatingSearchBar() {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      controller: _floatingSearchBarController,
      hint: 'Search Restaurants...',
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      automaticallyImplyBackButton: false,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        this.clientsToFilter = clientsToFilter.where((element) => element.name.toLowerCase().startsWith(query)).toList();
        if(this.clientsToFilter.isEmpty || query.isEmpty){
          this.clientsToFilter.addAll(this.clients);
        }
        setState(() {});
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: clientsToFilter.map((client) {
                return ListTile(
                  title: Text(client.name),
                  subtitle: Text(client.distance.floor().toString()+" km"),
                  onTap: (){
                    filterClients(client);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
    filterClients(Client client){
      clients.clear();
      clients.add(client);
      _floatingSearchBarController.close();
      setState(() {});
    }
  @override
  void dispose() {
    _floatingSearchBarController.dispose();
    super.dispose();
  }
}
