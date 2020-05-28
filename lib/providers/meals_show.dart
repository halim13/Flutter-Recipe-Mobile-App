import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/SearchSuggestion.dart';
import '../models/MealShow.dart';
import 'package:http/http.dart' as http;

class MealsShow with ChangeNotifier {

  List<SearchSuggestionsData> searchSuggestions = [];
  List<SearchSuggestionsData> get searchSuggestionsItem => [...searchSuggestions];

  List<MealShowData> showMeal = [];
  List<MealShowData> get showMealItem => [...showMeal];

  Future<void> refreshMeals(String mealId) async {
    await show(mealId);
  }

  Future<void> suggestions() async {
    String url = 'http://192.168.1.10:5000/api/v1/meals/search-suggestions'; // 192.168.43.85 || 10.0.2.2
    // wifi kantor 192.168.1.11
    // yang samsung 192.168.43.226
    try {
      http.Response response = await http.get(url);
      SearchSuggestionModel model = SearchSuggestionModel.fromJson(json.decode(response.body));
      List<SearchSuggestionsData> loadedSearchSuggestions = model.data;
      searchSuggestions = loadedSearchSuggestions;
      notifyListeners();
      return searchSuggestions;
    } catch(error) {
      print(error); // in-development
    }
  }

  Future<void> popularViews(String mealId) async {
    String url = 'http://192.168.1.10:5000/api/v1/meals/popular-views/$mealId'; // 192.168.43.85 || 10.0.2.2
    // wifi kantor 192.168.1.11
    // yang samsung 192.168.43.226
    try { 
      await http.get(url);
      suggestions();
      notifyListeners();
    } catch(error) {
      print(error); // in-development
      throw error;
    }
  }

  Future<void> show(String mealId, [int limit = 0]) async {
    limit = limit + 5;
    String url = 'http://192.168.1.10:5000/api/v1/meals/show/$mealId?limit=$limit'; // 192.168.43.85 || 10.0.2.2
    // wifi kantor 192.168.1.11
    // yang samsung 192.168.43.226
    try {
      http.Response response = await http.get(url);
      MealShowModel model = MealShowModel.fromJson(json.decode(response.body));
      List<MealShowData> loadedMeal = model.data;
      showMeal = loadedMeal;
      suggestions();
      notifyListeners();
      return showMeal;
    } catch(error) {
      print(error); // in-development
      throw error;
    }
  }

}