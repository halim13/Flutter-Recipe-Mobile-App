import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/connection.dart';
import '../../models/RecipeShow.dart';

class MyRecipe with ChangeNotifier {

  List<RecipeShowModelData> show = [];
  List<RecipeShowModelData> get getShowItem => [...show];

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
      http.Response response = await http.get(url).timeout(Duration(seconds: 10));
      RecipeShowModel model = RecipeShowModel.fromJson(json.decode(response.body));
      List<RecipeShowModelData> initialShow = [];
      model.data.forEach((item) {
        initialShow.add(RecipeShowModelData(
          uuid: item.uuid,
          title: item.title,
          imageurl: item.imageurl,
          duration: item.duration,
          portion: item.portion,
          user: RecipeShowModelDataUser(
            uuid: item.user.uuid,
            name: item.user.name
          ),
          category: RecipeShowModelDataCategory(
            title: item.category.title
          ),
          country: RecipeShowModelDataCountry(
            name: item.country.name
          )
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