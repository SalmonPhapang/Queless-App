import 'package:flutter/material.dart';
import 'package:flutter_app/auth/Authentication.dart';
import 'package:flutter_app/model/Address.dart';
import 'package:flutter_app/service/AddressService.dart';
import 'package:flutter_app/utils/TopWaveClipper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:progress_dialog/progress_dialog.dart';

class EditAddressPage extends StatefulWidget {
  EditAddressPage({Key key, this.title,this.address}) : super(key: key);
  @override
  _EditAddressPageState createState() => _EditAddressPageState();

  final String title;
  final Address address;
}

class _EditAddressPageState extends State<EditAddressPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AddressService addressService = new AddressService();
  Auth auth = new Auth();
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
        message: 'Updating Address...',
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
      widget.address.userKey = await auth.getCurrentUser();
      bool isSaved = await addressService.update(widget.address);
      if(isSaved){
        progressDialog.hide();
        Navigator.pop(context);
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
                        children: <Widget>[
                          TextFormField(
                            obscureText: false,
                            style: style,
                            keyboardType: TextInputType.text,
                            initialValue:  widget.address.nickName,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0.sp, 5.0.sp, 5.0.sp, 5.0.sp),
                                hintText: "Nick Name",
                                labelText: 'Nick Name',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                            onSaved: (String value) {
                              widget.address.nickName = value;
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
                            initialValue:  widget.address.houseNumber,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0.sp, 5.0.sp, 5.0.sp, 5.0.sp),
                                hintText: "House NO",
                                labelText: 'House NO',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0.sp))),
                            onSaved: (String value) {
                              widget.address.houseNumber = value;
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
                            initialValue:  widget.address.streetName,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0.sp, 5.0.sp, 5.0.sp, 5.0.sp),
                                hintText: "Street Name",
                                labelText: 'Street Name',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0.sp))),
                            onSaved: (String value) {
                              widget.address.streetName = value;
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
                            initialValue:  widget.address.addressLine,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0.sp, 5.0.sp, 5.0.sp, 5.0.sp),
                                hintText: "Address Line",
                                labelText: 'Address Line',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0.sp))),
                            onSaved: (String value) {
                              widget.address.addressLine = value;
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
                            initialValue:  widget.address.suburb,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 5.0.sp, 5.0.sp, 5.0.sp),
                                hintText: "Suburb",
                                labelText: 'Suburb',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0.sp))),
                            onSaved: (String value) {
                              widget.address.suburb = value;
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
                            initialValue:  widget.address.city,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 5.0.sp, 5.0.sp, 5.0.sp),
                                hintText: "City",
                                labelText: 'City',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0.sp))),
                            onSaved: (String value) {
                              widget.address.city = value;
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
                            initialValue:  widget.address.province,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0.sp, 5.0.sp, 5.0.sp, 5.0.sp),
                                hintText: "Province",
                                labelText: 'Province',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0.sp))),
                            onSaved: (String value) {
                              widget.address.province = value;
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
                            initialValue:  widget.address.code,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0.sp, 5.0.sp, 5.0.sp, 5.0.sp),
                                hintText: "Postal Code",
                                labelText: "Postal Code",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                            onSaved: (String value) {
                              widget.address.code = value;
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
                                'Update',
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
