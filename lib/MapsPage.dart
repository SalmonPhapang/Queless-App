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
import 'package:location_permissions/location_permissions.dart';
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
    this.setState(() {
      client.distance = distance / 1000.0;
    });
    clients.sort((a, b) {
      return a.distance !=null && b.distance !=null ? a.distance.compareTo(b.distance) : -1;
    });
  }
  getClients() async{
    List<Placemark> newPlace = await placemarkFromCoordinates(_position.latitude,_position.longitude);
      Placemark placeMark  = newPlace[0];
    clients.clear();
    clients = await _clientService.fetchAll();
    clients.forEach((client) async {
      calculateDistance(client);
      LatLng position = new LatLng(double.parse(client.address.location.latitude), double.parse(client.address.location.longitude));
      _markers.add(new Marker(
          markerId: MarkerId(client.hashCode.toString()),
          position: position,
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: client.name,
            snippet: client.address.getFullAddress(),
          )));
    });
    // Query clientsReference = FirebaseDatabase.instance.reference().child("Clients").orderByChild("province").equalTo(placeMark.administrativeArea);
    // clientsReference.keepSynced(true);
    // await clientsReference.once().then((DataSnapshot snapshot){
    //   this.setState((){
    //
    //     var DATA = snapshot.value;
    //     for(var individualKey in DATA){
    //       Client client = new Client(individualKey['name'], individualKey['bio'], individualKey['city'], individualKey['suburb'],individualKey['address'],individualKey['cellNumber'],individualKey['website'],individualKey['profileUrl'],individualKey['latitude'],individualKey['longitude']);
    //       calculateDistance(client);
    //       clients.add(client);
    //       LatLng position = new LatLng(client.latitude, client.longitude);
    //       _markers.add(new Marker(
    //           markerId: MarkerId(client.hashCode.toString()),
    //           position: position,
    //           icon: BitmapDescriptor.defaultMarker,
    //           infoWindow: InfoWindow(
    //             title: client.name,
    //             snippet: client.address,
    //           )));
    //     }
    //   });
    // });
  }
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final topAppBar = NewGradientAppBar(
      elevation: 0.1,
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
            elevation: 15.0,
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
      setState(() {
        _gotoLocation(_position.latitude, _position.longitude);

      });
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
        margin: EdgeInsets.symmetric(vertical: 15.0),
        height: 70.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            Padding(padding: const EdgeInsets.all(5.0),
              child: clients.length != 0 ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: clients.length,
                  itemBuilder: (context,int _index){
                return Padding(padding: EdgeInsets.all(3.0),
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
              elevation: 15.0,
              borderRadius: BorderRadius.circular(40.0),
              shadowColor: Color(0x802196F3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.only(topRight: Radius.circular(80.0),bottomRight: Radius.circular(80.0)),
                      child: Image(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(_image),
                      ),
                    ),),
                  Container(
                    margin: EdgeInsets.only(right: 10.0),
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
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
          padding: const EdgeInsets.only(left: 2.0,right: 5.0),
          child: Container(
              child: Text(restaurantName,
                style: TextStyle(
                    color: Color(0xff6200ee),
                    fontSize: 8.0,
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
                        fontSize: 5.0,
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
                fontSize: 5.0,
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
        markers: _markers.toSet(),
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