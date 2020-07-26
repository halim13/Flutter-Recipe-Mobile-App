import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../constants/connection.dart';
import '../models/RecipeDetail.dart';
import '../models/RecipeFavourite.dart';


class RecipeDetail with ChangeNotifier {
  Data data;
  int favourite;

  List<RecipeFavouriteData> recipeFavourite = [];
  List<RecipeFavouriteData> displayRecipeFavourite = [];
  List<RecipeFavouriteData> availableRecipe = [];

  bool isRecipeFavorite(String recipeId) {
    return recipeFavourite.any((recipe) => recipe.uuid == recipeId);
  }
  void toggleFavourite(String recipeId) {
    if(favourite == 0) {
      updateToFavourite(recipeId, 1);
      recipeFavourite.add(
        availableRecipe.firstWhere((recipe) => recipe.uuid == recipeId)
      );
      favourite = 1;
      Fluttertoast.showToast(
        msg: 'Added to favourite.',
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.yellow.shade700,
        textColor: Colors.white
      );
      notifyListeners();
    } else {
      updateToFavourite(recipeId, 0);
      final existingIndex = recipeFavourite.indexWhere((recipe) => recipe.uuid == recipeId);
      if(existingIndex >= 0) {
        recipeFavourite.removeAt(existingIndex);
      }
      favourite = 0;
      Fluttertoast.showToast(
        msg: 'Removed to favourite.',
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.yellow.shade700,
        textColor: Colors.white
      );
      notifyListeners();
    }
  }
  Future<void> refreshRecipeFavourite() async {
    await getRecipeFavourite();
  }
  Future<void> getRecipeFavourite() async {
    String url = 'http://$baseurl:$port/api/v1/recipes/favourite'; 
    try {
      http.Response response = await http.get(url);
      RecipeFavouriteModel model = RecipeFavouriteModel.fromJson(json.decode(response.body));
      displayRecipeFavourite = model.data;
      notifyListeners();
    } catch(error) {
      print(error); // in-development
      throw error;
    }
  }
  Future<void> updateToFavourite(String recipeId, int isfavourite) async {
    String url = 'http://$baseurl:$port/api/v1/recipes/update/favourite/$recipeId';
    try {
      await http.put(url, body: {
        "isFavourite": json.encode(isfavourite)
      });
      notifyListeners();
    } catch(error) {
      print(error); // in-development
      throw error;
    }
  }
  Future<void> detail(String recipeId) async {
    String url = 'http://$baseurl:$port/api/v1/recipes/detail/$recipeId';
    try {
      http.Response response = await http.get(url);
      RecipeDetailModel model = RecipeDetailModel.fromJson(json.decode(response.body));
      data = model.data;
      favourite = data.recipes.first.isfavourite;
      data.recipes.forEach((item) {
        availableRecipe.add(
          RecipeFavouriteData(
            uuid: item.uuid,
            title: item.title,
            isfavourite: item.isfavourite
          )
        );
      });
      notifyListeners();
    } catch(error) {
      print(error); // in-development
      throw error;
    }
  }
}
