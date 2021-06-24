import 'package:flutter_app/model/Address.dart';

class User{
  String userID;
  String name,email,password,cellNumber,gender;
  Map<String,Address> addresses;
  User(this.userID,this.name,this.email,this.password,this.cellNumber,this.addresses);
  toJson(){
    return {
      "UID":userID,
      "name":name,
      "email":email,
      "password":password,
      "cellNumber":cellNumber,
      "addresses":addresses
    };
  }
}