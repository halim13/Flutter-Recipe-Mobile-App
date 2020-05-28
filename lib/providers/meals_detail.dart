import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../models/MealDetail.dart';
import '../models/MealFavourite.dart';


class MealsDetail with ChangeNotifier {
  Data data;
  int favourite;

  List<MealsFavouriteData> mealsFavourite = [];
  List<MealsFavouriteData> get mealsFavouriteItems => [...mealsFavourite];

  List<MealsFavouriteData> availableMeals = [];

  List<MealDetailData> detailMeals = [];
  List<MealDetailData> get detailMealsItems => [...detailMeals];

  bool isMealFavorite(String mealId) {
    return mealsFavourite.any((meal) => meal.id == mealId);
  }

  void toggleFavourite(String mealId) {
    if(favourite == 0) {
      updateToFavourite(mealId, 1);
      mealsFavourite.add(
        availableMeals.firstWhere((meal) => meal.id == mealId)
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
      updateToFavourite(mealId, 0);
      final existingIndex = mealsFavourite.indexWhere((meal) => meal.id == mealId);
      if(existingIndex >= 0) {
        mealsFavourite.removeAt(existingIndex);
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

  Future<void> refreshMealsFavourite() async {
    await getMealsFavourite();
  }

  Future<void> getMealsFavourite() async {
    String url = 'http://192.168.1.10:5000/api/v1/meals/favourite'; // 192.168.43.85 || 10.0.2.2
    // wifi kantor 192.168.1.11
    // yang samsung 192.168.43.226
    try {
      http.Response response = await http.get(url);
      MealsFavouriteModel model = MealsFavouriteModel.fromJson(json.decode(response.body));
      mealsFavourite = model.data;
      notifyListeners();
    } catch(error) {
      print(error); // in-development
      throw error;
    }
  }
  
  Future<void> updateToFavourite(String mealId, int isfavourite) async {
    String url = 'http://192.168.1.10:5000/api/v1/meals/update/favourite/$mealId'; // 192.168.43.85 || 10.0.2.2
    // wifi kantor 192.168.1.11
    // yang samsung 192.168.43.226
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

  Future<void> detail(String mealId) async {
    String url = 'http://192.168.1.10:5000/api/v1/meals/detail/$mealId'; // 192.168.43.85 || 10.0.2.2
    // wifi kantor 192.168.1.11
    // yang samsung 192.168.43.226
    try {
      http.Response response = await http.get(url);
      MealDetailModel model = MealDetailModel.fromJson(json.decode(response.body));
      data = model.data;
      favourite = data.meals.first.isfavourite;
      data.meals.forEach((item) {
        availableMeals.add(
          MealsFavouriteData(
            id: item.id,
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
