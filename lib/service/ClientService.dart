import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_app/model/Client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ClientService {
  var dio = Dio();
  final String path = dotenv.env['SERVER_URL']+'client';

  Future<List<Client>> fetchAll() async{
    List<Client> clients = [];
    final response = await dio.get(path+'/fetch/all');
    if(response.statusCode == HttpStatus.ok){
      for(var individualKey in response.data){
        clients.add(Client.fromJson(individualKey));
      }
    }
    return clients;
  }
  Future<List<Client>> fetchCanOrder() async{
    List<Client> clients = [];
    final response = await dio.get(path+'/fetch/order');
    if(response.statusCode == HttpStatus.ok){
      for(var individualKey in response.data){
        clients.add(Client.fromJson(individualKey));
      }
    }
    return clients;
  }
  Future<Client> fetchByKey(key) async {
    Client client;
    final response = await dio.get(path+'/fetch/$key');
    if(response.statusCode == HttpStatus.ok){
      client = Client.fromJson(response.data);
    }
    return client;
  }
  Future<bool> checkCoverage(String city) async {
    final response = await dio.get(path+'/coverage/$city');
    if(response.statusCode == HttpStatus.ok){
      return response.data;
    }
    return false;
  }
}