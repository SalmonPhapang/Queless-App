import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/Client.dart';
import 'package:flutter_app/utils/FadeIn.dart';
import 'package:flutter_app/utils/TopWaveClipper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';

import 'service/AddressService.dart';
import 'service/ClientService.dart';

class DetailsPage extends StatefulWidget {
  DetailsPage({Key key, this.title,this.uniqueKey}) : super(key: key);

  final String title;
  final String uniqueKey;

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  Client client;
  ClientService _clientService = new ClientService();
  AddressService _addressService = new AddressService();

  Future<Client> getClient() async{
    client = await _clientService.fetchByKey(widget.uniqueKey);
    client.address =  await _addressService.fetchByClientKey(client.key);
    return client;
  }
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final topAppBar = NewGradientAppBar(
      elevation: 0.1.sp,
      gradient: LinearGradient(colors: [Colors.cyan,Colors.indigo]),
      title: Text(widget.title),
    );

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: topAppBar,
        body:Center(
            child: FutureBuilder(
        future: getClient(),
    builder: (context,snapshot){
          if(snapshot.hasData){
            return new SingleChildScrollView(
              child:Container(
                margin: EdgeInsets.only(top: 10.0.sp),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    FadeIn(1,Container(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            child:CachedNetworkImage(imageUrl: client.profileUrl,fit:BoxFit.cover ,fadeInDuration: Duration(milliseconds: 1000),),
                            width: 70.0.sp,
                            height:70.0.sp,
                          ),
                          Text(client.name,style: TextStyle(fontSize: 20.0.sp,color: Colors.blue,fontWeight: FontWeight.bold),),
                        ],
                      ),
                    )),
                    FadeIn(2, Card(
                        color: Colors.transparent,
                        elevation: 15.0.sp,
                        margin:EdgeInsets.all(10.0.sp),
                        child:  new Container(
                          decoration: new BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0.sp)),
                            gradient:LinearGradient(
                                colors: TopWaveClipper.blueGradients,
                                begin: Alignment.topLeft,
                                end: Alignment.center),
                          ),
                          child:   new Column(
                            children: <Widget>[
                              ListTile(
                                title: Text("Address",style: TextStyle(color: Colors.white),),
                                subtitle:Text(client.address.getFullAddress(),style: TextStyle(fontSize: 11.0.sp,color: Colors.white),) ,
                                leading:Icon(Icons.location_on, size: 12.0.sp, color: Colors.white),
                              ),
                              ListTile(
                                title: Text("Email",style: TextStyle(color: Colors.white),),
                                subtitle:Text(client.email,style: TextStyle(fontSize: 11.0.sp,color: Colors.white),) ,
                                leading:Icon(Icons.location_on, size: 12.0.sp, color: Colors.white),
                              ),
                              ListTile(
                                title: Text("Cell",style: TextStyle(color: Colors.white),),
                                subtitle:Text(client.cellNumber,style: TextStyle(fontSize: 11.0.sp,color: Colors.white),) ,
                                leading:Icon(Icons.phone, size: 12.0.sp, color: Colors.white),
                              ),
                              ListTile(
                                title: Text("City",style: TextStyle(color: Colors.white),),
                                subtitle:Text(client.address.city,style: TextStyle(fontSize: 11.0.sp,color: Colors.white),) ,
                                leading:Icon(Icons.location_city, size: 12.0.sp, color: Colors.white),
                              ),
                              ListTile(
                                title: Text("Suburb",style: TextStyle(color: Colors.white),),
                                subtitle:Text(client.address.suburb,style: TextStyle(fontSize: 11.0.sp,color: Colors.white),) ,
                                leading:Icon(Icons.airline_seat_individual_suite, size: 12.0.sp, color: Colors.white),
                              ),
                            ],
                          ) ,
                        )

                    )),
                  ],
                )
              )

            );
          }else if(snapshot.hasError){
            return Text("${snapshot.error}");
          }else{
            return SpinKitCubeGrid(color: Color(0xffff5722));
          }
    }))
    );
  }
}