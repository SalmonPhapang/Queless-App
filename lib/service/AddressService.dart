import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_app/model/Address.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddressService {
  var dio = Dio();
  final String path = dotenv.env['SERVER_URL']+'feed';

  Future<Address> fetchByUserKey(key) async{
    Address address;
    final response = await dio.get(path+'/fetch/user/$key');
    if(response.statusCode == HttpStatus.ok){
      for(var individualKey in response.data){
        address = Address.fromJson(individualKey);
      }
    }
    return address;
  }
  Future<Address> fetchByKey(key) async {
    Address address;
    dio.get(path+'/fetch/$key').then((response) => {
      if(response.statusCode == HttpStatus.ok){
        address = Address.fromJson(response.data),
      }
    });
    return address;
  }
}