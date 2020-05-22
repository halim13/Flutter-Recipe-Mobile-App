import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Recipe extends ChangeNotifier {
  Future store(String ingredients) async {
    String url = 'http://192.168.43.85:5000/api/v1/recipes/store'; // 192.168.43.85 || 10.0.2.2
    try {
      http.Response response = await http.post(url, body: {
        "ingredients": ingredients
      });
      // final responseData = jsonDecode(data);
      notifyListeners();
      // return responseData;
    } catch(error) {
      print(error);
    }
  }
}