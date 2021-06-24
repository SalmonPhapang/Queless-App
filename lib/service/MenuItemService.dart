import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_app/model/Feed.dart';
import 'package:flutter_app/model/MenuItem.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MenuItemService {
  var dio = Dio();
  final String path = dotenv.env['SERVER_URL']+'menu';

  Future<List<MenuItem>> fetchAll() async{
    List<MenuItem> items = [];
    final response = await dio.get(path+'/fetch/all');
    if(response.statusCode == HttpStatus.ok){
      for(var individualKey in response.data){
        items.add(MenuItem.fromJson(individualKey));
      }
    }
    return items;
  }
  Future<Feed> fetchByKey(key) async {
    Feed feed;
    dio.get(path+'/fetch/$key').then((response) => {
      if(response.statusCode == HttpStatus.ok){
        feed = Feed.fromJson(jsonDecode(response.data)),
      }
    });
    return feed;
  }
  Future<List<Feed>> fetchByClient(key) async {
    dio.get(path + '/fetch/client/$key');
  }
}