import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/menu/Cart.dart';
import 'package:flutter_app/menu/Menu.dart';
import 'package:flutter_app/menu/OrderCart.dart';
import 'package:flutter_app/model/Client.dart';
import 'package:flutter_app/model/MenuList.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:provider/provider.dart';

import 'service/AddressService.dart';
import 'service/ClientService.dart';

class OrdersClientPage extends StatefulWidget {
  OrdersClientPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _OrdersClientPageState createState() => _OrdersClientPageState();
}

class _OrdersClientPageState extends State<OrdersClientPage> {
  Client client;
  List<Client> clients = [];
  ClientService _clientService = new ClientService();
  AddressService _addressService = new AddressService();
  getClients() async {
    clients = await _clientService.fetchAll();
    clients.forEach((client) async {
      client.address =  await _addressService.fetchByClientKey(client.key);
    });
  }

  @override
  void initState() {
    super.initState();
    getClients();
  }

  @override
  Widget build(BuildContext context) {
    var bloc = Provider.of<OrderCart>(context);
    final topAppBar = NewGradientAppBar(
      elevation: 0.1,
      gradient: LinearGradient(colors: [Colors.cyan,Colors.indigo]),
      title: Text(widget.title),
    );
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: topAppBar,
        body: new Stack(
            children: <Widget>[
              new Container(
                  child: clients.length != 0 ? ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: clients.length,
                      itemBuilder: (context, int _index) {
                        return clientUI(clients[_index]);
                      }) : new Center(child: SpinKitCubeGrid(color: Color(0xffff5722),size: 50.0,))
              ),
              bloc.cart.length != 0 ? new Positioned(
                bottom: 10.0,
                child:  Align(
                  alignment: Alignment.bottomCenter,
                  child: new InkWell(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CartPage()),
                      );
                    },
                    child: new Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 25.0,right: 25.0),
                      height: 55.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.topRight,
                              colors: [
                                Colors.cyan,
                                Colors.indigo,
                              ]
                          )
                      ),
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Text(
                            bloc.cart.length.toString()+' Item(s)',
                            softWrap: true,
                            style: new TextStyle(
                              fontSize: 15.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.start,
                          ),
                          new Text(
                            'R'+bloc.total.toString(),
                            softWrap: true,
                            style: new TextStyle(
                              fontSize: 15.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      )
                    ),),
                )): new Container()
            ])
    );
  }

  String generateSubOptions(Map menu){

    String sub = "";
    int length = 0;
    Map categories = menu['Categories'];

    if(categories.keys.length > 5){
      length = 5;
    }else{
      length = categories.keys.length;
    }
    for(int i = 1; i < length; i++){
      sub += categories.values.elementAt(i)['name']+", ";
    }
    return sub;
  }
  Widget clientUI(Client client) {
    return new Card(
      elevation: 15.0,
      margin: EdgeInsets.all(12.0),
      child: new Container(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                new Center(child: Image.asset('assets/loader2.gif',height:60.0,fit: BoxFit.fitWidth,)),
          new InkWell(
                onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (
                context) =>
                MenuPage(title:"Menu")),);
             },
              child : Center(
                  child: CachedNetworkImage(imageUrl: "",
                    fit: BoxFit.fitWidth,
                    fadeInDuration: Duration(milliseconds: 1000),),
                )
          ),
              ],
            ),
            new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new Container(
                          width: 50.0,
                          height: 50.0,
                          margin: EdgeInsets.all(10.0),
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                  client.profileUrl),
                            ),
                          ),
                        ),
                    new Container(
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          textDirection: TextDirection.ltr,
                          children: <Widget>[
                            new Text(
                              client.name,
                              style: new TextStyle(
                                  fontSize: 17.0,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold
                              ),
                              textAlign: TextAlign.start,
                            ),
                            new Text(
                              generateSubOptions(null),
                              style: new TextStyle(
                                  fontSize: 10.0,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold
                              ),
                              textAlign: TextAlign.start,
                            )
                          ],
                        )
                    ),
                  ],
                ), //Row
              ],
            )
          ], //[Widget]
        ), //Column
      ), //Container
    ); //Cards ,
  }
}