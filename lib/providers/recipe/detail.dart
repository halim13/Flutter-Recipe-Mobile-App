import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../../constants/connection.dart';
import '../../models/RecipeDetail.dart' as recipeDetailModel;
import '../../models/RecipeFavourite.dart' as recipeFavoriteModel;

class RecipeDetail with ChangeNotifier {
  recipeDetailModel.RecipeDetailDatas data;
  int favourite;

  List<recipeFavoriteModel.RecipeFavouriteData> displayRecipeFavourite = [];

  bool isRecipeFavorite(String recipeId, int f) => favourite == 1 ? true : false;

  void toggleFavourite(String recipeId, int f, BuildContext context) {
    if(favourite == 0) {
      updateToFavourite(recipeId, 1);
      favourite = 1;
      Fluttertoast.showToast(
        msg: 'Berhasil menambahkan ke daftar favorit',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.yellow.shade700,
        textColor: Colors.white
      );
      notifyListeners();
    } else {
      updateToFavourite(recipeId, 0);
      displayRecipeFavourite.removeWhere((el) => el.uuid == recipeId);
      favourite = 0;
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
    String url = 'http://$baseurl:$port/api/v1/recipes/favourite'; 
    try {
      http.Response response = await http.get(url).timeout(Duration(seconds: 5));
      recipeFavoriteModel.RecipeFavouriteModel model = recipeFavoriteModel.RecipeFavouriteModel.fromJson(json.decode(response.body));
      List<recipeFavoriteModel.RecipeFavouriteData> initialDisplayRecipeFavorite = [];
      model.data.forEach((item) {
        initialDisplayRecipeFavorite.add(
         recipeFavoriteModel.RecipeFavouriteData(
            id: item.id,
            uuid: item.uuid,
            title: item.title,
            imageUrl: item.imageUrl,
            portion: item.portion,
            duration: item.duration,
            isfavourite: item.isfavourite,
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
  Future<void> updateToFavourite(String recipeId, int isfavourite) async {
    String url = 'http://$baseurl:$port/api/v1/recipes/update/favourite/$recipeId';
    try {
      await http.put(url, body: {
        "isFavourite": json.encode(isfavourite)
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
      favourite = model.data.recipes.first.isfavourite;
      notifyListeners();
    } catch(error) {
      print(error);
      throw error;
    }
  }
}