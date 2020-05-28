import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/RecipeEdit.dart';

class Recipe extends ChangeNotifier {
  Data data;

  List<Recipes> get getRecipes => [...data.recipes];
  List<Ingredients> get getIngredients => [...data.ingredients];
  List<Steps> get getSteps => [...data.steps];

  Future edit(String mealId) async {
    String url = 'http://192.168.1.10:5000/api/v1/recipes/edit/$mealId'; // 192.168.43.85 || 10.0.2.2
    // wifi kantor 192.168.1.11
    // yang samsung 192.168.43.226
    try {
      http.Response response = await http.get(url);
      RecipeEditModel model = RecipeEditModel.fromJson(json.decode(response.body));
      data = model.data;
      notifyListeners();
    } catch(error) {
      print(error);
    }
  }

  Future store(String title, String ingredients, String steps, String categoryId, File file) async {
    final prefs = await SharedPreferences.getInstance();
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    String userId = extractedUserData["userId"];
    String url = 'http://192.168.1.10:5000/api/v1/recipes/store'; // 192.168.43.85 || 10.0.2.2
    // wifi kantor 192.168.1.11
    // yang samsung 192.168.43.226
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
      notifyListeners();
      return responseDataDecoded;
    } catch(error) {
      print(error);
    }
  }

  Future update(String title, String mealId, File file, String ingredients, String steps, String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    String userId = extractedUserData["userId"];
    String url = 'http://192.168.1.10:5000/api/v1/recipes/update/$mealId'; // 192.168.43.85 || 10.0.2.2
    // wifi kantor 192.168.1.11
    // yang samsung 192.168.43.226
    // http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
    //   'imageurl', file.path 
    // );
    try {
      http.MultipartRequest request = http.MultipartRequest('PUT', Uri.parse(url));
      // request.files.add(multipartFile);
      request.fields["title"] = title;
      request.fields["ingredients"] = ingredients;
      request.fields["steps"] = steps;
      request.fields["categoryId"] = categoryId;
      request.fields["userId"] = userId; 
      http.StreamedResponse response = await request.send();
      String responseData = await response.stream.bytesToString();
      notifyListeners();
    } catch(error) {
      print(error);
    }
  }

}