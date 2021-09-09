import 'package:flutter_app/model/Address.dart';

class User{
  String key;
  String name,lastName,email,password,cellNumber,fcmToken;
  bool status,emailVerified,mobileApp;
  User({this.key,this.name,this.lastName,this.email,this.cellNumber,this.status,this.emailVerified,this.mobileApp});
  User.from({this.name,this.lastName,this.email,this.cellNumber,this.status,this.emailVerified,this.fcmToken,this.mobileApp});
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      key: json['key'],
      name: json['name'],
      lastName: json['surname'],
      email: json['email'],
      cellNumber: json['cellNumber'],
      status: json['status'],
      emailVerified: json['emailVerified'],
      mobileApp: json['mobileApp'],
    );
  }
  Map<String, dynamic> toJson() => {
    'name': name,
    'surname': lastName,
    'email': email,
    'cellNumber': cellNumber,
    'status': status,
    'fcmToken': fcmToken,
    'mobileApp': mobileApp,
    'emailVerified':emailVerified
  };
}