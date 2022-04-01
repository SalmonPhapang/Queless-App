import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_app/model/Feed.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:localstorage/localstorage.dart';

class FeedService {
  var dio = Dio();
  final storage = new LocalStorage('queless-app.json');
  final String path = dotenv.env['SERVER_URL']+'feed';

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
  Future<List<Feed>> fetchPages(String startAt,int pageSize) async{
    List<Feed> feeds = [];
    final response = await dio.get(path+'/fetch/client/all/$startAt/$pageSize');
    if(response.statusCode == HttpStatus.ok){
      for(var individualKey in response.data){
        feeds.add(Feed.fromJson(individualKey));
      }
    }
    return feeds;
  }
  Future<List<Feed>> fetchPaginate(String startAt,int pageSize) async{
    List<Feed> feeds = [];
    final response = await dio.get(path+'/fetch/client/all/$startAt/$pageSize');
    if(response.statusCode == HttpStatus.ok){
      for(var individualKey in response.data){
        feeds.add(Feed.fromJson(individualKey));
      }
    }
    return feeds;
  }
  Future<List<Feed>> fetchPaginateLimit(int pageSize) async{
    List<Feed> feeds = [];
    final response = await dio.get(path+'/fetch/client/all/$pageSize');
    if(response.statusCode == HttpStatus.ok){
      for(var individualKey in response.data){
        feeds.add(Feed.fromJson(individualKey));
      }
    }
    return feeds;
  }
  Future<Feed> fetchByKey(key) async {
    Feed feed;
    final response = await dio.get(path+'/fetch/$key');
    if(response.statusCode == HttpStatus.ok){
      feed = Feed.fromJson(response.data);
  }
    return feed;
  }
  Future<List<Feed>> fetchByClient(key) async {
    dio.get(path + '/fetch/client/$key');
  }
}