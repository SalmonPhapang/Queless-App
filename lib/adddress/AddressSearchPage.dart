import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/auth/Authentication.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/model/Address.dart';
import 'package:flutter_app/model/User.dart';
import 'package:flutter_app/service/AddressService.dart';
import 'package:flutter_app/service/ClientService.dart';
import 'package:flutter_app/utils/BottomWaveClipper.dart';
import 'package:flutter_app/utils/TopWaveClipper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:page_transition/page_transition.dart';
import 'package:progress_dialog/progress_dialog.dart';

class AddressSearchPage extends StatefulWidget {
  AddressSearchPage({Key key, this.title,this.user}) : super(key: key);

  @override
  _AddressSearchPageState createState() => _AddressSearchPageState();

  final String title;
  final User user;
}

class _AddressSearchPageState extends State<AddressSearchPage> {
  Auth auth = new Auth();
  AddressService addressService = new AddressService();
  ClientService clientService = new ClientService();
  Address address = new Address();
  Position _position;
  List<Placemark> placemarks;

  @override
  void initState() {
    getLocation();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(fontFamily: 'sans-serif', fontSize: 15.0.sp);
    final topAppBar = NewGradientAppBar(
      elevation: 0.1.sp,
      gradient: LinearGradient(colors: [Colors.cyan, Colors.indigo]),
      title: Text(widget.title),
      actions: <Widget>[
       IconButton(
          icon: Icon(
            Icons.add,
            color: Colors.white,
            size: 25.0.sp,
          ),
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },)
      ],
    );
    ProgressDialog progressDialog = new ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    progressDialog.style(
        message: 'Finishing Up...',
        borderRadius: 10.0.sp,
        backgroundColor: Colors.white,
        progressWidget: SpinKitCubeGrid(color: Color(0xffff5722),size: 25.0.sp,),
        elevation: 10.0.sp,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0.sp,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 11.0.sp, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 18.0.sp, fontWeight: FontWeight.w600)
    );
    Future<void> _saveAddress(Placemark placemark) async {
      progressDialog.show();
      address.nickName = 'Default';
      address.houseNumber = ' ';
      address.city = placemark.locality;
      address.suburb = placemark.subLocality;
      address.code = placemark.postalCode;
      address.streetName = placemark.street;
      address.province = placemark.administrativeArea;
      address.addressLine = placemark.subAdministrativeArea;
      address.primary = true;
      address.userKey = await auth.getCurrentUser();
      bool isSaved = await addressService.save(this.address);
      if(isSaved){
        progressDialog.hide();
        Fluttertoast.showToast(msg: "Welcome "+ widget.user.name,toastLength: Toast.LENGTH_LONG);
        Navigator.pushAndRemoveUntil(
          context,
          PageTransition(type: PageTransitionType.rightToLeft, child: BottomNavBar()),
              (route) => false,
        );
      }
    }
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: topAppBar,
        body: new Container(
            child: FutureBuilder(
        future: getLocation(),
    builder: (context,snapshot){
    if(snapshot.hasData){
      return ListView.builder(
            itemCount: placemarks.length,
            itemBuilder: (context, index) {
              return Card(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(child: ListTile(
                          title: Text(
                              '${placemarks.elementAt(index).name}'),
                          subtitle: Text('${placemarks.elementAt(index).street}' ' ${placemarks.elementAt(index).locality}' ' ${placemarks.elementAt(index).subLocality}' ' ${placemarks.elementAt(index).administrativeArea}' ' ${placemarks.elementAt(index).postalCode}') ,
                        ),
                        ),
                        new InkWell(
                          onTap: () =>{
                           _saveAddress(placemarks.elementAt(index))
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
                      ])
              );
            },
          );
    }else if(snapshot.hasError){
      return Center(child:Text("${snapshot.error}"));
    }else{
      return Center(child:SpinKitCubeGrid(color: Color(0xffff5722)));
    }
        })));
  }

  Future<bool> getLocation() async {
    try {
      checkPermission();
      _position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
        placemarks = await placemarkFromCoordinates(
          _position.latitude, _position.longitude);
      setState(() {});
    } on Exception catch (e) {
      print('Could not get location: ${e.toString()}');
    }
    return true;
  }

  void checkPermission() async {
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
}
