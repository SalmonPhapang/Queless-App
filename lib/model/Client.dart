import 'dart:collection';

import 'Address.dart';

class Client{
  String key,name,bio,cellNumber,email,enterpriseNumber,website,profileUrl;
  Address address;
  double distance;

  Client({this.key,this.name,this.bio,this.address,this.cellNumber,this.email,this.website,this.enterpriseNumber,this.profileUrl});

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      key: json['key'],
      name: json['userName'],
      email: json['email'],
      cellNumber: json['contactNumber'],
      website: json['website'],
      profileUrl: json['profileImage'],
    );
  }
  Map<String, dynamic> toJson() => {
    'key': key,
    'name': name,
    'email': email,
    'cellNumber': cellNumber,
    'website': website,
    'profileUrl': profileUrl,
    'address': address,
  };
  setDistance(double distance){
    this.distance = distance;
  }
}