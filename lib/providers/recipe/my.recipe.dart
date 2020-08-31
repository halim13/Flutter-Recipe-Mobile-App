import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/connection.dart';
import '../../models/RecipeShow.dart';

class MyRecipe with ChangeNotifier {

  List<RecipeShowData> show = [];
  List<RecipeShowData> get getShowItem => [...show];

  Future<void> refreshRecipe() async {
    await getShow();
  }

  Future<void> getShow([int limit = 0]) async {
    limit = limit + 5;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, Object> extractedUserData = json.decode(prefs.getString('userData'));
    String userId = extractedUserData["userId"];
    String url = 'http://$baseurl:$port/api/v1/recipes/show/me/$userId?limit=$limit'; 
    try {
      http.Response response = await http.get(url).timeout(Duration(seconds: 60));
      RecipeShowModel model = RecipeShowModel.fromJson(json.decode(response.body));
      List<RecipeShowData> initialShow = [];
      model.data.forEach((item) {
        initialShow.add(RecipeShowData(
          uuid: item.uuid,
          title: item.title,
          imageurl: item.imageurl,
          duration: item.duration,
          name: item.name, 
          userId: item.userId,
          portion: item.portion
        ));
      });
      show = initialShow;
      notifyListeners();
    } catch(error) {
      print(error);
      throw error;
    }
  }

}