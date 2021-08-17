import 'package:flutter_app/model/Location.dart';

class Address {
  String key,userKey,houseNumber,streetName,addressLine,city,suburb,province,code,nickName,fullAddress;
  Location location;

  Address({this.key,this.userKey,this.nickName,this.streetName,this.houseNumber,this.addressLine,this.city,this.suburb,this.province,this.code,this.location});
  String getFullAddress(){
    return this.fullAddress = this.houseNumber +" "+ this.streetName + " "+  this.addressLine +","+ " "+ this.suburb + "," +" "+ this.province + " "+ this.code;
  }
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      key: json['key'],
      userKey: json['userKey'],
      nickName: json['nickName'],
      streetName: json['streetName'],
      houseNumber: json['houseNumber'],
      addressLine: json['addressLine'],
      city: json['city'],
      suburb: json['suburb'],
      province: json['province'],
      code: json['code'],
      location: Location.fromJson(json['location'])
    );
  }
  Map<String, dynamic> toJson() => {
    'userKey': userKey,
    'nickName': nickName,
    'streetName': streetName,
    'houseNumber': houseNumber,
    'addressLine': addressLine,
    'city': city,
    'suburb': suburb,
    'province':province,
    'code':code,
    'location':location,
  };
}