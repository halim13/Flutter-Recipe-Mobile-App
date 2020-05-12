import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  String userId;
  String userName;
  String  userEmail;
  DateTime _expiryDate;
  Timer authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null && _expiryDate.isAfter(DateTime.now()) && _token != null) {
      return _token;
    }
    return _token;
  }
  Future<void> auth(String token) async {
    String url = 'http://192.168.43.85:5000/api/v1/accounts';
    try {
      http.Response response = await http.get(url, headers: {
        "x-auth-token" : token 
      });
      final responseData = json.decode(response.body);
      _token = token;
      userId = responseData["data"]["id"];
      userName = responseData["data"]["name"];
      userEmail = responseData["data"]["email"];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: responseData["data"]['expiresIn'],
        ),
      );
      autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': token,
          'userId': userId,
          'userEmail': userEmail,
          'userName': userName,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch(error) {
      print(error);
      throw error;
    }
  }

  Future<void> login(String email, String password) async {
    String url = 'http://192.168.43.85:5000/api/v1/accounts/login'; // 192.168.43.85 || 10.0.2.2
    try {
      http.Response response = await http.post(url, 
      body: {
        "email": email,
        "password": password
      });
      final responseData = json.decode(response.body);
      auth(responseData["data"]);
    } catch(error) {
      print(error);
      throw error;
    }
  }

  Future<void> register(String name, String email, String password) async {
    String url = 'http://192.168.43.85:5000/api/v1/accounts/register'; // 192.168.43.85 || 10.0.2.2
    try {
      http.Response response = await http.post(url, body: {
        "name": name,
        "email": email,
        "password" : password
      });
    } catch(error) {
      print(error);
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    userId = extractedUserData['userId'];
    userName = extractedUserData['userName'];
    userEmail = extractedUserData['userEmail'];
    _expiryDate = expiryDate;
    notifyListeners();
    autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    userId = null;
    userName = null;
    userEmail = null;
    _expiryDate = null;
    if (authTimer != null) {
      authTimer.cancel();
      authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData'); specify remove
    prefs.clear();
  }

  void autoLogout() {
    if (authTimer != null) {
      authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}