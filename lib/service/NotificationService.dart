import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_app/model/NotificationDTO.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationService {
  var dio = Dio();
  final String path = dotenv.env['SERVER_URL'] + 'notification';

  Future<String> send(NotificationDTO notification) async {
    final response = await dio.post(path+'/send/',data: notification);
    if(response.statusCode == HttpStatus.ok){
      return response.data;
    }
    return "";
  }
}