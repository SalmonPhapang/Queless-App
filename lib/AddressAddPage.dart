import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/model/Address.dart';
import 'package:flutter_app/model/User.dart';
import 'package:flutter_app/utils/BottomWaveClipper.dart';
import 'package:flutter_app/utils/TopWaveClipper.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'auth/Authentication.dart';
import 'service/AddressService.dart';

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
  AddressService addressService = new AddressService();
  Address address = new Address();
  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(fontFamily: 'sans-serif', fontSize: 15.0.sp);
    final topAppBar = NewGradientAppBar(
      elevation: 0.1.sp,
      gradient: LinearGradient(colors: [Colors.cyan,Colors.indigo]),
      title: Text(widget.title),
    );

    ProgressDialog progressDialog = new ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: true, showLogs: false);
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
    Future<void> _saveAddress() async {
      progressDialog.show();
      address.userKey = await auth.getCurrentUser();
      bool isSaved = await addressService.save(this.address);
      if(isSaved){
        progressDialog.hide();
        Fluttertoast.showToast(msg: "Welcome "+ widget.user.name,toastLength: Toast.LENGTH_LONG);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavBar()),);
      }
    }
    void _validateForm() {
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();
        _saveAddress();
      }
    }
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: topAppBar,
        body: new Container(
          child: SingleChildScrollView(child:  new Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child:new Card(
                elevation: 5.0.sp,
                margin:EdgeInsets.all(5.0.sp),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.sp),
                ),
                child: new Container(
                    padding: new EdgeInsets.all(5.0.sp),
                    height: MediaQuery.of(context).size.height.sp,
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        TextFormField(
                            obscureText: false,
                            style: style,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0.sp, 5.0.sp, 5.0.sp, 5.0.sp),
                                hintText: "Nick Name",
                                suffixText: '*',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                            onSaved: (String value) {
                              this.address.nickName = value;
                            },
                            validator: (String arg) {
                              if(arg.isEmpty)
                                return 'Nick Name is required';
                              else
                                return null;
                            },
                          ),//nameField,

                       TextFormField(
                            obscureText: false,
                            style: style,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0.sp, 5.0.sp, 5.0.sp, 5.0.sp),
                                hintText: "House NO",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0.sp))),
                            onSaved: (String value) {
                              this.address.houseNumber = value;
                            },
                            validator: (String arg) {
                              if(arg.isEmpty)
                                return 'House NO is required';
                              else
                                return null;
                            },
                          ),//nameField,
                        TextFormField(
                            obscureText: false,
                            style: style,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0.sp, 5.0.sp, 5.0.sp, 5.0.sp),
                                hintText: "Street Name",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0.sp))),
                            onSaved: (String value) {
                              this.address.streetName = value;
                            },
                            validator: (String arg) {
                              if(arg.isEmpty)
                                return 'Street Name is required';
                              else
                                return null;
                            },
                          ),//nameField,
                        TextFormField(
                            obscureText: false,
                            style: style,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0.sp, 5.0.sp, 5.0.sp, 5.0.sp),
                                hintText: "Address Line",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0.sp))),
                            onSaved: (String value) {
                              this.address.addressLine = value;
                            },
                            validator: (String arg) {
                              if(arg.isEmpty)
                                return 'Address Line is required';
                              else
                                return null;
                            },
                          ),//nameField,
                        TextFormField(
                            obscureText: false,
                            style: style,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 5.0.sp, 5.0.sp, 5.0.sp),
                                hintText: "Suburb",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0.sp))),
                            onSaved: (String value) {
                              this.address.suburb = value;
                            },
                            validator: (String arg) {
                              if(arg.isEmpty)
                                return 'Suburb is required';
                              else
                                return null;
                            },
                          ),//nameField,
                        TextFormField(
                          obscureText: false,
                          style: style,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20.0, 5.0.sp, 5.0.sp, 5.0.sp),
                              hintText: "City",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0.sp))),
                          onSaved: (String value) {
                            this.address.city = value;
                          },
                          validator: (String arg) {
                            if(arg.isEmpty)
                              return 'City is required';
                            else
                              return null;
                          },
                        ),//nameField
                        TextFormField(
                            obscureText: false,
                            style: style,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0.sp, 5.0.sp, 5.0.sp, 5.0.sp),
                                hintText: "Province",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0.sp))),
                            onSaved: (String value) {
                              this.address.province = value;
                            },
                            validator: (String arg) {
                              if(arg.isEmpty)
                                return 'Province is required';
                              else
                                return null;
                            },
                          ),//nameField,
                        TextFormField(
                            obscureText: false,
                            style:style,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0.sp, 5.0.sp, 5.0.sp, 5.0.sp),
                                hintText: "Postal Code",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                            onSaved: (String value) {
                              this.address.code = value;
                            },
                            validator: (String arg) {
                              if(arg.isEmpty)
                                return 'Postal Code is required';
                              else
                                return null;
                            },
                          ),//nameField,
                        new InkWell(
                          onTap: () {
                            _validateForm();
                          },
                          child: new Container(
                            width: MediaQuery.of(context).size.width,
                            height: 40.0.sp,
                            margin: EdgeInsets.only(top: 5.0.sp,bottom: 10.0.sp),
                            padding: EdgeInsets.only(top: 8.sp),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(5.0.sp)),
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
                                  fontSize: 19.0.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),)
                      ],)
                )),
          ))
        )
    );
  }
}
