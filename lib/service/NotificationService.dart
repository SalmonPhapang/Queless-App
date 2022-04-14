import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_app/model/NotificationDTO.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationService {
  var dio = Dio();
  final String path = dotenv.env['SERVER_URL'] + 'notification';

  Future<String> send(Notification notification) async {
    final response = await dio.post(path+'/send',data: notification);
    if(response.statusCode == HttpStatus.ok){
      return response.data;
    }
    return "";
  }
  Future<String> sendSms(orderKey) async {
    final response = await dio.post(path+'/send/sms/$orderKey/');
    if(response.statusCode == HttpStatus.ok){
      return response.data;
    }
    return "";
  }
  Future<bool> sendOTP(String number,String otp) async {
    final response = await dio.post(path+'/send/otp/$number/$otp');
    if(response.statusCode == HttpStatus.ok){
      return response.data;
    }
    return false;
  }
}