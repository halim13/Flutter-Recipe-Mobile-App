import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../../constants/connection.dart';
import '../../models/RecipeDetail.dart' as recipeDetailModel;
import '../../models/RecipeFavorite.dart' as recipeFavoriteModel;

class RecipeDetail with ChangeNotifier {
  recipeDetailModel.RecipeDetailDatas data;
  int favorite;

  List<recipeFavoriteModel.RecipeFavoriteData> displayRecipeFavourite = [];

  bool isRecipeFavorite(String recipeId, int f) => favorite == 1 ? true : false;

  void toggleFavorite(String recipeId, int f, BuildContext context) {
    if(favorite == 0) {
      updateToFavorite(recipeId, 1);
      favorite = 1;
      Fluttertoast.showToast(
        msg: 'Berhasil menambahkan ke daftar favorit',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.yellow.shade700,
        textColor: Colors.white
      );
      notifyListeners();
    } else {
      updateToFavorite(recipeId, 0);
      displayRecipeFavourite.removeWhere((el) => el.uuid == recipeId);
      favorite = 0;
      Fluttertoast.showToast(
        msg: 'Berhasil hapus dari daftar favorit',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.yellow.shade700,
        textColor: Colors.white
      );
      if(ModalRoute.of(context).settings.name == "/recipe-detail-favorite") {
        Navigator.of(context).pop(true);
        notifyListeners();
      }
      notifyListeners();
    }
  }

  Future<void> refreshRecipeFavourite() async {
    await getRecipeFavourite();
  }
  
  Future<void> getRecipeFavourite() async {
    String url = 'http://$baseurl:$port/api/v1/recipes/favorite'; 
    try {
      http.Response response = await http.get(url).timeout(Duration(seconds: 60));
      recipeFavoriteModel.RecipeFavoriteModel model = recipeFavoriteModel.RecipeFavoriteModel.fromJson(json.decode(response.body));
      List<recipeFavoriteModel.RecipeFavoriteData> initialDisplayRecipeFavorite = [];
      model.data.forEach((item) {
        initialDisplayRecipeFavorite.add(
         recipeFavoriteModel.RecipeFavoriteData(
            id: item.id,
            uuid: item.uuid,
            title: item.title,
            imageUrl: item.imageUrl,
            portion: item.portion,
            duration: item.duration,
            isfavorite: item.isfavorite,
            userId: item.userId,
            name: item.name
          )
        );
      });
      displayRecipeFavourite = initialDisplayRecipeFavorite;
      notifyListeners();
    } catch(error) {
      print(error); 
      throw error;
    }
  }

  Future<void> updateToFavorite(String recipeId, int isfavourite) async {
    String url = 'http://$baseurl:$port/api/v1/recipes/update/favorite/$recipeId';
    try {
      await http.put(url, body: {
        "isFavorite": json.encode(isfavourite)
      });
      notifyListeners();
    } catch(error) {
      print(error);
      throw error;
    }
  }

  Future<void> detail(String recipeId) async {
    String url = 'http://$baseurl:$port/api/v1/recipes/detail/$recipeId';
    try {
      http.Response response = await http.get(url);
      recipeDetailModel.RecipeDetailModel model = recipeDetailModel.RecipeDetailModel.fromJson(json.decode(response.body));
      data = model.data;
      favorite = model.data.recipes.first.isfavorite;
      notifyListeners();
    } catch(error) {
      print(error);
      throw error;
    }
  }
  
}