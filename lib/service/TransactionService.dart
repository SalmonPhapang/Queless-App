import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_app/model/Address.dart';
import 'package:flutter_app/model/Transaction.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TransactionService {
  var dio = Dio();
  final String path = dotenv.env['SERVER_URL']+'transaction';

  Future<Transaction> fetchByOrderKey(key) async{
    Transaction transaction;
    final response = await dio.get(path+'/fetch/order/$key');
    if(response.statusCode == HttpStatus.ok){
      transaction = Transaction.fromJson(response.data);
    }
    return transaction;
  }
  Future<Transaction> fetchByKey(key) async {
    Transaction transaction;
    final response = await dio.get(path+'/fetch/$key');
    if(response.statusCode == HttpStatus.ok){
      transaction = Transaction.fromJson(response.data);
  }
    return transaction;
  }

  Future<bool> save(Transaction transaction) async {
    final response = await dio.post(path + '/save',data: transaction);
    if(response.statusCode == HttpStatus.ok) {
      return response.data;
    }
  }
}