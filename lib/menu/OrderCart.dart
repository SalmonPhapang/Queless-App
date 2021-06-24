import 'package:flutter/material.dart';
import 'package:flutter_app/model/Address.dart';
import 'package:flutter_app/model/MenuItem.dart';

class OrderCart with ChangeNotifier {
  List<MenuItem> _cart = [];
  List<MenuItem> get cart => _cart;

  Address _address;
  Address get address => _address;

  double _total;
  double get total => _total;

  bool addToCart(MenuItem item) {
    if (!_cart.contains(item)) {
      _cart.add(item);
     double itemTotal = 0.0;
     double fee = 5.0;
     for(var item in cart){
        itemTotal += item.price;
      }
      _total = itemTotal + fee;
     return true;
    } else {
      return false;
    }
    notifyListeners();
  }

  void setAddress(Address address){
    _address = address;
  }
  void clear(MenuItem item) {
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
