import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_app/model/Order.dart';
import 'package:flutter_app/model/OrderItem.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OrderService {
  var dio = Dio();
  final String path = dotenv.env['SERVER_URL']+'order';

  Future<List<Order>> fetchByUser(key) async{
    List<Order> orders = [];
    final response = await dio.get(path+'/fetch/user/$key');
    if(response.statusCode == HttpStatus.ok){
      for(var individualKey in response.data){
        Order order = Order.fromJson(individualKey);
        List<OrderItem> orderItems = [];
        List items = individualKey["orderItems"];
        items.forEach((element) {
          orderItems.add(OrderItem.fromJson(element));
        });
        order.orderItems = orderItems;
        orders.add(order);
      }
    }
    return orders;
  }
  Future<Order> fetchByKey(key) async {
    Order order;
    final response = await dio.get(path+'/fetch/$key');
    if(response.statusCode == HttpStatus.ok){
      order = Order.fromJson(response.data);
   }
    return order;
  }
  Future<String> save(Order order) async {
    final response = await dio.post(path + '/save/',data: order);
    if(response.statusCode == HttpStatus.ok) {
      return response.data;
    }
  }
}