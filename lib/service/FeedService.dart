import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_app/model/Client.dart';
import 'package:flutter_app/model/Feed.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'ClientService.dart';

class FeedService {
  var dio = Dio();
  final String path = dotenv.env['SERVER_URL']+'feed';
  ClientService _clientService = new ClientService();
  Future<List<Feed>> fetchAll() async{
    List<Feed> feeds = [];
    final response = await dio.get(path+'/fetch/client/all');
    if(response.statusCode == HttpStatus.ok){
      for(var individualKey in response.data){
        feeds.add(Feed.fromJson(individualKey));
    }
  }
    return feeds;
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