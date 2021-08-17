import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_app/model/Credentials.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class AuthenticationService {
  var dio = Dio();
  final String path = dotenv.env['SERVER_URL'] + 'auth';

  Future<String> signIn(Credentials credentials) async {
    final response = await dio.post(path+'/signIn/');
    if(response.statusCode == HttpStatus.ok){
      return response.data;
    }
  }

  Future<String> save(Credentials credentials) async {
    final response = await dio.post(path + '/save/',data: credentials);
    if(response.statusCode == HttpStatus.ok) {
      return response.data;
    }
  }
}