import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/Address.dart';
import 'package:flutter_app/model/User.dart';
import 'package:flutter_app/utils/BottomWaveClipper.dart';
import 'package:flutter_app/utils/TopWaveClipper.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'auth/Authentication.dart';

class AddressAddPage extends StatefulWidget {
  AddressAddPage({Key key, this.title,this.user}) : super(key: key);
  @override
  _AddressAddPageState createState() => _AddressAddPageState();

  final String title;
  final User user;
}

class _AddressAddPageState extends State<AddressAddPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  Auth auth = new Auth();
  @override
  Widget build(BuildContext context) {
    Address address = new Address();
    List<Address> addresses = new List();
    final topAppBar = NewGradientAppBar(
      elevation: 0.1,
      gradient: LinearGradient(colors: [Colors.cyan,Colors.indigo]),
      title: Text(widget.title),
    );
    Future<void> _saveAddress() async {
      addresses.add(address);
      firebaseAuth.User firebaseUser = await auth.getCurrentUser();
      FirebaseDatabase.instance.reference().child("Users").child(firebaseUser.uid)
          .child("Addresses").push().set("").then((value) => {
            Fluttertoast.showToast(msg: "New address has been saved",toastLength: Toast.LENGTH_SHORT),
            Navigator.pop(context)
      });
    }
    void _validateForm() {
      if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
        _formKey.currentState.save();
        _saveAddress();
      }
    }
    // final _geoMethods = address_search.GeoMethods(
    //   googleApiKey: 'AIzaSyBkhAGfWiWn2eNyZBZDMEAFr9YPTbyScGE',
    //   language: 'en',
    //   countryCode: 'za',
    //   country: 'South Africa',
    //   city: 'Johannesburg',
    // );
    // final _controller = TextEditingController();

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: topAppBar,
        body: new Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color(0xFF1b1e44),
                    Color(0xFF2d3447),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  tileMode: TileMode.clamp)),
          child:  new Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.always,
            child:new Card(
              elevation: 15.0,
              margin:EdgeInsets.all(10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: new Container(
                  padding: new EdgeInsets.all(15.0),
                  child: new Column(
                    children: <Widget>[
                    //       Container(
                    //       child: Center(
                    //         child: TextField(
                    //         controller: _controller,
                    //         onTap: () => showDialog(
                    //           context: context,
                    //           builder: (_) => address_search.AddressSearchBuilder.deft(
                    //             geoMethods: _geoMethods,
                    //             controller: _controller,
                    //             builder: address_search.AddressDialogBuilder(),
                    //             onDone: (address_search.Address  address) {
                    //               print(address);
                    //             },
                    //           ),
                    //         ),
                    //       ),
                    //   ),
                    // ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child:TextFormField(
                            obscureText: false,
                            style: TextStyle(fontFamily: 'Montserrat', fontSize: 10.0),
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                hintText: "Nick Name",
                                suffixText: '*',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                            onSaved: (String value) {
                              address.nickName = value;
                            },
                          validator: (String arg) {
                            if(arg.isEmpty)
                              return 'Nick Name is required';
                            else
                              return null;
                          },
                        ),//nameField,
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child:TextFormField(
                            obscureText: false,
                            style: TextStyle(fontFamily: 'Montserrat', fontSize: 10.0),
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                hintText: "House NO",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                            onSaved: (String value) {
                              address.houseNumber = value;
                            },
                          validator: (String arg) {
                            if(arg.isEmpty)
                              return 'House NO is required';
                            else
                              return null;
                          },
                        ),//nameField,
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child:TextFormField(
                            obscureText: false,
                            style: TextStyle(fontFamily: 'Montserrat', fontSize: 10.0),
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                hintText: "Street Name",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                            onSaved: (String value) {
                              address.streetName = value;
                            },
                          validator: (String arg) {
                            if(arg.isEmpty)
                              return 'Street Name is required';
                            else
                              return null;
                          },
                        ),//nameField,
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child:TextFormField(
                            obscureText: false,
                            style: TextStyle(fontFamily: 'Montserrat', fontSize: 10.0),
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                hintText: "Address Line",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                            onSaved: (String value) {
                              address.addressLine = value;
                            },
                          validator: (String arg) {
                            if(arg.isEmpty)
                              return 'Address Line is required';
                            else
                              return null;
                          },
                        ),//nameField,
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child:TextFormField(
                            obscureText: false,
                            style: TextStyle(fontFamily: 'Montserrat', fontSize: 10.0),
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                hintText: "Suburb",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                            onSaved: (String value) {
                              address.suburb = value;
                            },
                          validator: (String arg) {
                            if(arg.isEmpty)
                              return 'Suburb is required';
                            else
                              return null;
                          },
                        ),//nameField,
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child:TextFormField(
                            obscureText: false,
                            style: TextStyle(fontFamily: 'Montserrat', fontSize: 10.0),
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                hintText: "Province",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                            onSaved: (String value) {
                              address.province = value;
                            },
                          validator: (String arg) {
                            if(arg.isEmpty)
                              return 'Province is required';
                            else
                              return null;
                          },
                        ),//nameField,
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child:TextFormField(
                            obscureText: false,
                            style: TextStyle(fontFamily: 'Montserrat', fontSize: 10.0),
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                hintText: "Postal Code",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                            onSaved: (String value) {
                              address.code = value;
                            },
                          validator: (String arg) {
                            if(arg.isEmpty)
                              return 'Postal Code is required';
                            else
                              return null;
                          },
                        ),//nameField,
                      ),
                      new InkWell(
                        onTap: () {
                          _validateForm();
                        },
                        child: new Container(
                          width: MediaQuery.of(context).size.width,
                          height: 40.0,
                          padding: EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.topRight,
                                  colors:TopWaveClipper.orangeGradients
                              )
                          ),
                          child: new Text(
                            'Save',
                            softWrap: true,
                            style: new TextStyle(
                                fontSize: 19.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),)
                    ],)
              )),
          )
        )
    );
  }
}
