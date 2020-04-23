import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/MealShow.dart';
import 'package:http/http.dart' as http;

class MealsShow with ChangeNotifier {

  List<MealShowData> showMeal = [];
  List<MealShowData> get showMealItem {
    return [...showMeal];
  }

  Future<void> refreshMeals(String mealId) async {
    await show(mealId);
  }

  Future<void> show(String mealId) async {
    String url = 'http://192.168.43.85:5000/api/v1/meals/show/$mealId'; // 192.168.43.85 || 10.0.2.2
    try {
      http.Response response = await http.get(url);
      MealShowModel model = MealShowModel.fromJson(json.decode(response.body));
      List<MealShowData> loadedMeal = model.data;
      showMeal = loadedMeal;
      notifyListeners();
      return showMeal;
    } catch(error) {
      print(error); // in-development
      throw error;
    }
  }

}