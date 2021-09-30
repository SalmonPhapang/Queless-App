import 'package:flutter_app/model/OrderItem.dart';

import 'Address.dart';

class Order{

  String key,userKey,clientKey,addressKey,orderNumber,orderTime,preparedTime,collectedTime,orderStatus;
  double fee,subTotal,total,driverTip;
  List<OrderItem> orderItems;
  bool collection,delivery;
  Address address;

  Order({this.key,this.userKey,this.clientKey,this.addressKey,this.orderNumber,this.orderTime,this.preparedTime,this.collectedTime,this.orderStatus,this.fee,this.subTotal,this.total,this.driverTip,this.orderItems, this.collection,this.delivery});
  Order.from({this.userKey,this.clientKey,this.addressKey,this.fee,this.subTotal,this.total,this.driverTip,this.orderItems});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      key: json['key'],
      userKey: json['userKey'],
      clientKey: json['clientKey'],
      addressKey: json['addressKey'],
      orderNumber: json['orderNumber'],
      orderTime: json['orderTime'],
      preparedTime: json['preparedTime'],
      collection: json['collection'],
      delivery: json['delivery'],
      collectedTime: json['collectedTime'],
      orderStatus: json['orderStatus'],
      fee: json['fee'],
      subTotal: json['subTotal'],
      total: json['total'],
      driverTip: json['driverTip'],
    );
  }
  Map<String, dynamic> toJson() => {
    'userKey': userKey,
    'clientKey': clientKey,
    'addressKey': addressKey,
    'collection': collection,
    'delivery': delivery,
    'fee': fee,
    'subTotal': subTotal,
    'total':total,
    'driverTip': driverTip,
    'orderItems': orderItems
  };

}