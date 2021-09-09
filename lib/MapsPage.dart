import 'dart:async';
import 'dart:ffi';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/model/Client.dart';
import 'package:flutter_app/utils/FadeIn.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';

import 'model/Address.dart';
import 'service/AddressService.dart';
import 'service/ClientService.dart';
class MapsPage extends StatefulWidget {
  MapsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  Completer<GoogleMapController> _controller = Completer();
  Position _position;
  List<Marker> _markers = [];
  List<Client> clients = [];
  ClientService _clientService = new ClientService();
  AddressService _addressService = new AddressService();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  calculateDistance(Client client) async{
    double distance =  await Geolocator.distanceBetween(_position.latitude, _position.longitude, double.parse(client.address.location.latitude), double.parse(client.address.location.longitude));
    clients.sort((a, b) {
      return a.distance !=null && b.distance !=null ? a.distance.compareTo(b.distance) : -1;
    });
    this.setState(() {
      client.distance = distance / 1000.0;
    });
  }
  Set<Marker> _createMarker() {
    return _markers.toSet();
  }
  getClients() async{
    clients.clear();
    clients = await _clientService.fetchAll();

    for(var client in clients){
      client.address =  await _addressService.fetchByClientKey(client.key);
      calculateDistance(client);
      LatLng position = new LatLng(double.parse(client.address.location.latitude), double.parse(client.address.location.longitude));
      _markers.add(new Marker(
          markerId: MarkerId(client.key),
          position: position,
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: client.name,
            snippet: client.address.getFullAddress(),
          )));
      setState(() {});
    }
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
      backgroundColor:  Color.fromRGBO(245, 245, 245, 1),
      appBar: topAppBar,
      body: Stack(
        children: <Widget>[
          _googleMap(context),
          _buildContainer(),
          Align(
          child : FloatingActionButton(
            onPressed: () {
              getLocation();
            },
            child: Icon(Icons.my_location),
            backgroundColor: Color(0xFF03A0FE),
            mini: true,
            elevation: 15.0.sp,
          ),
            alignment: Alignment.topRight,
          ),
        ],
      )
    );
  }

  Future<bool> getLocation() async {
    try {
        checkPermission();
       _position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
         getClients();
        _gotoLocation(_position.latitude, _position.longitude);
        setState(() {});

    } on Exception catch (e) {
      print('Could not get location: ${e.toString()}');
    }
    return true;
  }

  void updateLocation() async {
  }
  void checkPermission() async{
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
    }
  }
  Widget _buildContainer() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 15.0.sp),
        height: 70.0.sp,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            Padding(padding:  EdgeInsets.all(5.0.sp),
              child: clients.length != 0 ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: clients.length,
                  itemBuilder: (context,int _index){
                return Padding(padding: EdgeInsets.all(3.0.sp),
                    child:  FadeIn((_index + 1).toDouble(),_boxes(clients[_index].profileUrl, double.parse(clients[_index].address.location.latitude),double.parse(clients[_index].address.location.longitude),clients[_index].name,clients[_index].address.suburb,clients[_index].address.city,clients[_index].distance))) ;
              }) : null
            ),
          ],
        ),
      ),
    );
  }
  Widget _boxes(String _image, double lat,double long,String restaurantName,String suburb,String address,double distance) {
    return  GestureDetector(
      onTap: () {
        _gotoLocation(lat,long);
      },
      child:Container(
        width: 110.0,
        child: new FittedBox(
          child: Material(
              color: Colors.white,
              elevation: 15.0.sp,
              borderRadius: BorderRadius.circular(40.0.sp),
              shadowColor: Color(0x802196F3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 40.sp,
                    height: 40.sp,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.only(topRight: Radius.circular(80.0.sp),bottomRight: Radius.circular(80.0.sp)),
                      child: Image(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(_image),
                      ),
                    ),),
                  Container(
                    margin: EdgeInsets.only(right: 10.0.sp),
                    child: Padding(
                      padding:  EdgeInsets.all(1.0.sp),
                      child: detailsContainer(restaurantName,suburb,address,distance),
                    ),
                  ),

                ],)
          ),
        ),
      ),
    );
  }

  Widget detailsContainer(String restaurantName,String suburb,String city,double distance) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 2.0.sp,right: 5.0.sp),
          child: Container(
          constraints: new BoxConstraints(
          maxWidth: 50.sp),
              child: Text(restaurantName,
                style: TextStyle(
                    color: Color(0xff6200ee),
                    fontSize: 8.0.sp,
                    fontWeight: FontWeight.bold),
              )),
        ),
        Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                    child: Text(
                      suburb,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 5.0.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ],
            )),
        Container(
            child: Text(
              distance != null ? distance.round().toString()+" Km":"",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 5.0.sp,
                fontWeight: FontWeight.bold,
              ),
            )),
      ],
    );
  }
  Widget _googleMap(BuildContext context) {
    return Container(
      height: MediaQuery
          .of(context)
          .size
          .height,
      width: MediaQuery
          .of(context)
          .size
          .width,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        markers: _createMarker(),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
           getLocation();
        },
      ),
    );
  }


  Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long), zoom: 16,))).whenComplete((){
    });
  }
}