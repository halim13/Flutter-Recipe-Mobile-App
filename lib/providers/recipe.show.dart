import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/SearchSuggestion.dart';
import '../models/RecipeShow.dart';
import '../constants/connection.dart';

class RecipeShow with ChangeNotifier {

  List<SearchSuggestionsData> searchSuggestions = [];
  List<SearchSuggestionsData> get searchSuggestionsItem => [...searchSuggestions];

  List<RecipeShowData> showRecipe = [];
  List<RecipeShowData> get showRecipeItem => [...showRecipe];
  
  Future<void> refreshRecipe(String recipeId) async {
    await show(recipeId);
  }
  Future<void> suggestions() async {
    String url = 'http://$baseurl:$port/api/v1/recipes/search-suggestions';
    try {
      http.Response response = await http.get(url);
      SearchSuggestionModel model = SearchSuggestionModel.fromJson(json.decode(response.body));
      List<SearchSuggestionsData> loadedSearchSuggestions = model.data;
      searchSuggestions = loadedSearchSuggestions;
      notifyListeners();
      return searchSuggestions;
    } catch(error) {
      print(error);
    }
  }
  Future<void> popularViews(String recipeId) async {
    String url = 'http://$baseurl:$port/api/v1/recipes/popular-views/$recipeId';
    try { 
      await http.get(url);
      suggestions();
      notifyListeners();
    } catch(error) {
      print(error);
      throw error;
    }
  }
  Future<void> show(String recipeId, [int limit = 0]) async {
    limit = limit + 5;
    String url = 'http://$baseurl:$port/api/v1/recipes/show/$recipeId?limit=$limit'; 
    try {
      http.Response response = await http.get(url);
      RecipeShowModel model = RecipeShowModel.fromJson(json.decode(response.body));
      List<RecipeShowData> loadedRecipe = model.data;
      showRecipe = loadedRecipe;
      suggestions();
      notifyListeners();
      return showRecipe;
    } catch(error) {
      print(error);
      throw error;
    }
  }
}