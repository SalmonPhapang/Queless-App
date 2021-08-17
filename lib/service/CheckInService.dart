import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_app/model/CheckIn.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CheckInService {
  var dio = Dio();
  final String path = dotenv.env['SERVER_URL']+'checkIn';
  Future<List<CheckIn>> fetchByUser(key) async{
    List<CheckIn> checkIns = [];
    final response = await dio.get(path+'/fetch/user/$key');
    if(response.statusCode == HttpStatus.ok){
      for(var individualKey in response.data){
        checkIns.add(CheckIn.fromJson(individualKey));
      }
    }
    return checkIns;
  }
  Future<String> save(CheckIn checkIn) async {
    final response = await dio.post(path + '/save',data:checkIn);
    if(response.statusCode == HttpStatus.ok){
      return response.data;
    }
  }
}