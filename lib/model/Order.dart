import 'package:flutter_app/model/Address.dart';
import 'package:flutter_app/model/MenuItem.dart';

class Order{

  String uuid,clientName,orderNumber,date,orderType,paymentMethod;
  List<MenuItem> items;
  String deliveryAddressUUID;
  double total,subTotal,fee;
  Order(this.clientName,this.orderNumber,this.date,this.items,this.total,this.subTotal,this.fee,this.orderType,this.paymentMethod,this.deliveryAddressUUID);

  toJson(){
    return {
      "clientName":clientName,
      "orderNumber":orderNumber,
      "date":date,
      "total":total.toString(),
      "subTotal":subTotal.toString(),
      "fee":fee.toString(),
      "orderType":orderType,
      "paymentMethod":paymentMethod,
      "deliveryAddressUUID":deliveryAddressUUID,
    };
  }

}