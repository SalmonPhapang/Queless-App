import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

abstract class BaseAuth {
  Future<User> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  Future<User> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();

  Future<void> changeEmail(String email);

  Future<void> changePassword(String password);

  Future<void> deleteUser();

  Future<void> sendPasswordResetMail(String email);
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<User> signIn(String email, String password) async {
    UserCredential authResult = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    User user = authResult.user;
    return user;
  }

  Future<String> signUp(String email, String password) async {
    UserCredential authResult = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    User user = authResult.user;
    return user.uid;
  }

   Future<User> getCurrentUser() async {
    User user = await _firebaseAuth.currentUser;
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    User user = await _firebaseAuth.currentUser;
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    User user = await _firebaseAuth.currentUser;
    return user.emailVerified;
  }

  @override
  Future<void> changeEmail(String email) async {
    User user = await _firebaseAuth.currentUser;
    user.updateEmail(email).then((_) {
      Fluttertoast.showToast(msg: "Succesfull changed email");
    }).catchError((error) {
      Fluttertoast.showToast(msg:"email can't be changed" + error.toString());
    });
    return null;
  }

  @override
  Future<void> changePassword(String password) async {
    User user = await _firebaseAuth.currentUser;
    user.updatePassword(password).then((_) {
      Fluttertoast.showToast(msg: "Succesfull changed password");
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Password can't be changed" + error.toString());
    });
    return null;
  }

  @override
  Future<void> deleteUser() async {
    User user = await _firebaseAuth.currentUser;
    user.delete().then((_) {
      Fluttertoast.showToast(msg:"Succesfull user deleted");
    }).catchError((error) {
      Fluttertoast.showToast(msg: "user can't be delete" + error.toString());
    });
    return null;
  }

  @override
  Future<void> sendPasswordResetMail(String email) async{
    await _firebaseAuth.sendPasswordResetEmail(email: email);
    return null;
  }

}