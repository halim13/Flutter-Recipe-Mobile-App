import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Recipe extends ChangeNotifier {

  Future store(String title, String ingredients, String steps, String categoryId, File file) async {
    final prefs = await SharedPreferences.getInstance();
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    String userId = extractedUserData["userId"];
    String url = 'http://192.168.43.85:5000/api/v1/recipes/store'; // 192.168.43.85 || 10.0.2.2
    try {
      http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(url));
      http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
        'imageurl', file.path 
      );
      request.files.add(multipartFile);
      request.fields["title"] = title;
      request.fields["ingredients"] = ingredients;
      request.fields["steps"] = steps;
      request.fields["categoryId"] = categoryId;
      request.fields["userId"] = userId; 
      http.StreamedResponse response = await request.send();
      String responseData = await response.stream.bytesToString();
      final responseDataDecoded = json.decode(responseData);   
      print(responseDataDecoded);
      notifyListeners();
      return responseData;
    } catch(error) {
      print(error);
    }

  }

}