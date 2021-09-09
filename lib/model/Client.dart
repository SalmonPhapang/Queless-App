import 'dart:collection';

import 'Address.dart';

class Client{
  String key,name,bio,cellNumber,email,enterpriseNumber,website,profileUrl,coverImage;
  Address address;
  double distance;
  bool online;

  Client({this.key,this.name,this.bio,this.address,this.cellNumber,this.email,this.website,this.enterpriseNumber,this.profileUrl,this.coverImage,this.online});

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      key: json['key'],
      name: json['name'],
      email: json['email'],
      cellNumber: json['contactNumber'],
      website: json['website'],
      profileUrl: json['profileImage'],
      coverImage: json['coverImage'],
      online: json['online'],
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
    'coverImage':coverImage,
    'online':online
  };
  setDistance(double distance){
    this.distance = distance;
  }
}