import 'dart:async';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_app/auth/Authentication.dart';
import 'package:flutter_app/menu/EditAddressPage.dart';
import 'package:flutter_app/menu/OrderCart.dart';
import 'package:flutter_app/menu/OrderSummary.dart';
import 'package:flutter_app/model/Address.dart';
import 'package:flutter_app/service/AddressService.dart';
import 'package:flutter_app/service/UserService.dart';
import 'package:flutter_app/utils/TopWaveClipper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:provider/provider.dart';

import 'NewAddressPage.dart';
class AddressPage extends StatefulWidget {
  AddressPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  AddressService addressService = new AddressService();
  Auth auth = new Auth();
  List<Address> address = [];
  bool empty;
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
        body:FutureBuilder(
        future: getAddress(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
          return ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: address.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                  Expanded(child: ListTile(
                    title: Text(
                        '${address[index].nickName}'),
                    subtitle: Text('${address[index].houseNumber} ${address[index].streetName} ${address[index].suburb} ${address[index].city} ${address[index].province} ${address[index].code}') ,
                  ),
                  ),
                        new InkWell(
                          onTap: () =>{
                             bloc.setAddress(address[index]),
                             Navigator.push(context, MaterialPageRoute(builder: (context) => OrderSummary()))
                          },
                          child: Container(
                            margin:EdgeInsets.only(top: 10.0,right: 5.0),
                            decoration: BoxDecoration(
                              gradient:LinearGradient(
                                  colors: TopWaveClipper.blueGradients,
                                  begin: Alignment.topLeft,
                                  end: Alignment.center),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 22.0, vertical: 6.0),
                                child: Text("Select",
                                    style: TextStyle(color: Colors.white,fontSize: 10)),
                              ),
                            ),
                          ),
                        ),
                        new InkWell(
                          onTap: () =>{
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EditAddressPage(title: "Edit",address: address[index],)))
                          },
                          child: Container(
                            margin:EdgeInsets.only(top: 10.0,right: 5.0),
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
                                child: Text("Edit",
                                    style: TextStyle(color: Colors.white,fontSize: 10)),
                              ),
                            ),
                          ),
                        )
                      ])
                );
              },
            );
      }else if (snapshot.hasError) {
        return Text("${snapshot.error}");
      } else {
        return Center(
          child: SpinKitCubeGrid(color: Color(0xffff5722)),
        );
      }
    }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF03A0FE),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => NewAddressPage(title: "New Address Details"))).then(onBack);
        },
      ),
    );

  }
  FutureOr onBack(dynamic value){
    getAddress();
    setState(() {});
  }
  Future<List> getAddress() async{
    String userKey = await auth.getCurrentUser();
    address = await addressService.fetchByUserKey(userKey);
    if(address == null || address.isEmpty){
      empty = true;
    }
    return address;
  }

}