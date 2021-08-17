import 'package:flutter_app/model/MenuItem.dart';

class OrderItem {
  String key, menuItemKey;
  int quantity;
  double total;
  MenuItem menuItem;

  OrderItem({this.key, this.menuItemKey, this.quantity, this.total});
  OrderItem.from(this.menuItem, this.quantity){
    this.total = menuItem.price * quantity;
    this.menuItemKey = menuItem.key;
  }
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      key: json['key'],
      menuItemKey: json['menuItemKey'],
      total: json['total'],
      quantity: json['quantity'],
    );
  }
  Map<String, dynamic> toJson() => {
    'menuItemKey': menuItemKey,
    'quantity': quantity,
    'total': total,
  };
}