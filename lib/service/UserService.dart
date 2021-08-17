import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_app/model/Credentials.dart';
import 'package:flutter_app/model/User.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserService {
  var dio = Dio();
  final String path = dotenv.env['SERVER_URL']+'user';

  Future<User> fetchByKey(key) async {
    User user;
    final response = await dio.get(path+'/fetch/$key');
    if(response.statusCode == HttpStatus.ok) {
      user = User.fromJson(response.data);
    }
    return user;
  }
    Future<String> signIn(Credentials credentials) async {
      final response = await dio.post(path + '/login/',data: credentials,);
      if(response.statusCode == HttpStatus.ok) {
        return response.data;
      }
    }
  Future<String> save(User user) async {
    final response = await dio.post(path + '/save/',data: user);
    if(response.statusCode == HttpStatus.ok) {
      return response.data;
    }
  }
  Future<String> update(User user) async {
    final response = await dio.put(path + '/update/${user.key}',data: user);
    if(response.statusCode == HttpStatus.ok) {
      return response.data;
    }
  }
  Future<bool> archive(String key) async {
    final response = await dio.post(path + '/archive/$key');
    if(response.statusCode == HttpStatus.ok) {
      return response.data;
    }
  }
}