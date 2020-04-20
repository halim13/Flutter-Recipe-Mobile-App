import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/meal.dart' as x;
import 'package:http/http.dart' as http;

class Meals with ChangeNotifier {
  x.Data data;
  int favouriteProv;
  
  List<x.MealDetailData> detailMeals = [];
  List<x.MealDetailData> get detailMealsItems {
    return [...detailMeals];
  }

  List<x.MealShowData> showMeal = [];
  List<x.MealShowData> get showMealItem {
    return [...showMeal];
  }

  List<x.MealsFavouriteData> availableMeals = [];
  
  List<x.MealsFavouriteData> mealsFavourite = [];
  List<x.MealsFavouriteData> get mealsFavouriteItems {
    return [...mealsFavourite];
  }

  Future<void> refreshFavourites() async {
    await getMealsFavourite();
  }

  Future<void> refreshMeals(String mealId) async {
    await show(mealId);
  }

  bool isMealFavorite(String mealId) {
    return mealsFavourite.any((meal) => meal.id == mealId);
  }

  void toggleFavourite(String mealId) {
    if(favouriteProv == 0) {
      updateToFavourite(mealId, 1);    
      mealsFavourite.add(
        availableMeals.firstWhere((meal) => meal.id == mealId),
      );
      notifyListeners();
    } else {
      updateToFavourite(mealId, 0);
      final existingIndex = mealsFavourite.indexWhere((meal) => meal.id == mealId);
      if(existingIndex >= 0) {
        mealsFavourite.removeAt(existingIndex);
      }
      notifyListeners();
    }
  } 
  
  Future<void> show(String mealId) async {
    String url = 'http://192.168.43.85:5000/api/v1/meals/show/$mealId'; // 192.168.43.85 || 10.0.2.2
    try {
      http.Response response = await http.get(url);
      x.MealShowModel model = x.MealShowModel.fromJson(json.decode(response.body));
      List<x.MealShowData> loadedMeal = model.data;
      showMeal = loadedMeal;
      notifyListeners();
      return showMeal;
    } catch(error) {
      print(error); // in-development
      throw error;
    }
  }
  Future<void> detail(String mealId) async {
    String url = 'http://192.168.43.85:5000/api/v1/meals/detail/$mealId'; // 192.168.43.85 || 10.0.2.2
    try {
      http.Response response = await http.get(url);
      x.MealDetailModel model = x.MealDetailModel.fromJson(json.decode(response.body));
      data = model.data;
      favouriteProv = data.meals.first.isfavourite;
      data.meals.forEach((item) {
        availableMeals.add(x.MealsFavouriteData(id: item.id));
      });
      notifyListeners();
    } catch(error) {
      print(error); // in-development
      throw error;
    }
  }
  Future<void> updateToFavourite(String mealId, int isfavourite) async {
    String url = 'http://192.168.43.85:5000/api/v1/meals/update/favourite/$mealId'; // 192.168.43.85 || 10.0.2.2
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
  Future<void> getMealsFavourite() async {
    String url = 'http://192.168.43.85:5000/api/v1/meals/favourite'; // 192.168.43.85 || 10.0.2.2
    try {
      http.Response response = await http.get(url);
      x.MealsFavouriteModel model = x.MealsFavouriteModel.fromJson(json.decode(response.body));
      mealsFavourite = model.data;
      notifyListeners();
    } catch(error) {
      print(error); // in-development
      throw error;
    }
  }
  
}