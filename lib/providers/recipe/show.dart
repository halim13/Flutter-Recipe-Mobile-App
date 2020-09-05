import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/SearchSuggestion.dart';
import '../../models/RecipeShow.dart';
import '../../constants/connection.dart';

class RecipeShow with ChangeNotifier {

  List<SearchSuggestionModelData> searchSuggestions = [];
  List<SearchSuggestionModelData> get getSearchSuggestionsItem => [...searchSuggestions];

  List<RecipeShowModelData> show = [];
  List<RecipeShowModelData> get getShowItem => [...show];
  
  Future<void> refreshRecipe(String recipeId) async {
    await getShow(recipeId);
  }

  Future<void> suggestions() async {
    String url = 'http://$baseurl:$port/api/v1/recipes/search-suggestions';
    try {
      http.Response response = await http.get(url).timeout(Duration(seconds: 10));
      SearchSuggestionModel model = SearchSuggestionModel.fromJson(json.decode(response.body));
      List<SearchSuggestionModelData> initialSearchSuggestionData = [];
      model.data.forEach((item) { 
        initialSearchSuggestionData.add(SearchSuggestionModelData(
          uuid: item.uuid, 
          title: item.title,
          imageurl: item.imageurl,
          duration: item.duration,
          portion: item.portion,
           user: SearchSuggestionModelDataUser(
            uuid: item.user.uuid,
            name: item.user.name
          ),
          category: SearchSuggestionModelDataCategory(
            title: item.category.title
          ),
          country: SearchSuggestionModelDataCountry(
            name: item.country.name
          )
        ));
      });
      searchSuggestions = initialSearchSuggestionData;
      notifyListeners();
      return searchSuggestions;
    } catch(error) {
      print(error);
    }
  }

  Future<void> popularViews(String recipeId) async {
    String url = 'http://$baseurl:$port/api/v1/recipes/popular-views/$recipeId';
    try { 
      await http.get(url).timeout(Duration(seconds: 10));
      suggestions();
      notifyListeners();
    } catch(error) {
      print(error);
      throw error;
    }
  }

  Future<void> getShow(String categoryId, [int limit = 0]) async {
    limit = limit + 5;
    String url = 'http://$baseurl:$port/api/v1/recipes/show/$categoryId?limit=$limit'; 
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
      suggestions();
      notifyListeners();
    } catch(error) {
      print(error);
      throw error;
    }
  }

}