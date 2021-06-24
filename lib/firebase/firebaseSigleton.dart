import 'package:firebase_database/firebase_database.dart';

class DatabaseInstance{
  FirebaseDatabase getInstance(){
    return FirebaseDatabase.instance;
  }
}