import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/exceptions/auth_exception.dart';

class Auth with ChangeNotifier {
  String _userId;
  String _token;
  DateTime _expiryDate;

  bool get isAuth{
    return token != null;
  }

  String get userId{
    return isAuth ? _userId : null;
  }

  String get token {
    if(_token != null && _expiryDate != null && _expiryDate.isAfter(DateTime.now())){
      return _token;
    }else{
      return null;
    }
  }

  Future<void> _authenticate(String email, String password, String urlSegment) async {
    final url = 'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBq99Z_x7WEoYG3P5s-7SlQBEvNC8zsILk';

    final response = await http.post(
        url,
        body: json.encode({
          "email": email,
          "password": password,
          "returnSecureToken": true,
        })
    );

    final responseBody = json.decode(response.body);
    if(responseBody["error"] != null){
      throw AuthException(responseBody['error']['message']);
    }else{
      _token = responseBody["idToken"];
      _userId = responseBody["localId"];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseBody["expiresIn"]),
        )
      );
      notifyListeners();
    }

    return Future.value();
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, "signUp");
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, "signInWithPassword");
  }

}