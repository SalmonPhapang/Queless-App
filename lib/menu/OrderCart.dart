import 'package:flutter/material.dart';
import 'package:flutter_app/model/Address.dart';
import 'package:flutter_app/model/MenuItem.dart';
import 'package:flutter_app/model/OrderItem.dart';

class OrderCart with ChangeNotifier {

  List<OrderItem> _cart = [];
  List<OrderItem> get cart => _cart;

  Address _address;
  Address get address => _address;

  double _subTotal;
  double get subTotal => _subTotal;

  double _fee = 30.0;
  double get fee => _fee;

  double _total;
  double get total => _total;

  bool addToCart(MenuItem menuItem,int quantity) {
      OrderItem orderItem  =  new OrderItem.from(menuItem,quantity);
      orderItem.menuItem = menuItem;
     bool contain = _cart.any((element) => element.menuItem.key == menuItem.key);
    if (!contain) {
      _cart.add(orderItem);
      double total =  0.0;
     for(var item in cart){
       total += item.total;
      }
      _subTotal = total;
      _total = _subTotal + fee;
      notifyListeners();
     return true;
    } else {
      return false;
    }

  }

  void setAddress(Address address){
    _address = address;
    notifyListeners();
  }
  void clear(OrderItem item) {
    if (_cart.contains(item)) {
      _cart.remove(item);
      notifyListeners();
    }
  }
  void clearAll() {
    _cart.clear();
    notifyListeners();
  }
}
