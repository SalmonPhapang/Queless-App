import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_app/model/Address.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddressService {
  var dio = Dio();
  final String path = dotenv.env['SERVER_URL']+'address';

  Future<List<Address>> fetchByUserKey(key) async{
    List<Address> addresses  = [];
    final response = await dio.get(path+'/fetch/user/$key');
    if(response.statusCode == HttpStatus.ok){
      for(var individualKey in response.data){
        addresses.add(Address.fromJson(individualKey));
      }
    }
    return addresses;
  }
  Future<Address> fetchByClientKey(key) async{
    Address address;
    final response = await dio.get(path+'/fetch/user/$key');
    if(response.statusCode == HttpStatus.ok){
        address = Address.fromJson(response.data[0]);
    }
    return address;
  }
  Future<Address> fetchByKey(key) async {
    Address address;
    final response = await dio.get(path+'/fetch/$key');
    if(response.statusCode == HttpStatus.ok){
      address = Address.fromJson(response.data);
  }
    return address;
  }

  Future<bool> save(Address address) async {
    final response = await dio.post(path + '/save/',data: address);
    if(response.statusCode == HttpStatus.ok) {
      return response.data;
    }
  }

  Future<bool> update(Address address) async {
    final response = await dio.post(path + '/update/${address.key}',data: address);
    if(response.statusCode == HttpStatus.ok) {
      return response.data;
    }
  }
}