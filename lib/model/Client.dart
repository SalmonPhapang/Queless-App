import 'dart:collection';

import 'Address.dart';

class Client{
  String key,name,bio,cellNumber,email,enterpriseNumber,website,profileUrl;
  Address address;
  double distance;

  Client({this.key,this.name,this.bio,this.address,this.cellNumber,this.email,this.website,this.enterpriseNumber,this.profileUrl});

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      name: json['name'],
      bio: json['bio'],
      email: json['email'],
      address: Address.fromJson(json['address']),
      cellNumber: json['cellNumber'],
      website: json['website'],
      profileUrl: json['profileUrl'],
    );
  }
  setDistance(double distance){
    this.distance = distance;
  }
}