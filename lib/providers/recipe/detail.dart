import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../../constants/connection.dart';
import '../../models/RecipeDetail.dart';
import '../../models/RecipeFavorite.dart';

class RecipeDetail with ChangeNotifier {
  List<RecipeDetailData> recipeDetail = [];
  List<IngredientsGroupDetail> ingredientsGroupDetail = [];
  List<StepDetailData> stepsDetail = [];
  int favorite;

  List<RecipeDetailData> get getRecipeDetail => [...recipeDetail];
  List<IngredientsGroupDetail> get getIngredientsGroupDetail => [...ingredientsGroupDetail];
  List<StepDetailData> get getStepsDetail => [...stepsDetail];

  List<RecipeFavoriteData> displayRecipeFavorite = [];

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
      displayRecipeFavorite.removeWhere((el) => el.uuid == recipeId);
      favorite = 0;
      Fluttertoast.showToast(
        msg: 'Berhasil hapus dari daftar favorit',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.yellow.shade700,
        textColor: Colors.white
      );
      if(ModalRoute.of(context).settings.name == "/detail-recipe-favorite") {
        Navigator.of(context).pop(true);
        notifyListeners();
      }
      notifyListeners();
    }
  }

  Future<void> refreshRecipeFavorite() async {
    await getRecipeFavorite();
  }
  
  Future<void> getRecipeFavorite() async {
    String url = 'http://$baseurl:$port/api/v1/recipes/favorite'; 
    try {
      http.Response response = await http.get(url).timeout(Duration(seconds: 10));
      RecipeFavoriteModel model = RecipeFavoriteModel.fromJson(json.decode(response.body));
      List<RecipeFavoriteData> initialDisplayRecipeFavorite = [];
      model.data.forEach((item) {
        initialDisplayRecipeFavorite.add(
         RecipeFavoriteData(
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
      displayRecipeFavorite = initialDisplayRecipeFavorite;
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
      RecipeDetailModel model = RecipeDetailModel.fromJson(json.decode(response.body));
      List<RecipeDetailData> initialRecipeDetail = [];
      List<IngredientsGroupDetail> initialIngredientsGroupDetail = [];
      List<StepDetailData> initialStepsDetail = [];
      model.data.recipes.forEach((item) { 
        initialRecipeDetail.add(RecipeDetailData(
          uuid: item.uuid,
          title: item.title,
          imageurl: item.imageurl,
          portion: item.portion,
          duration: item.duration,
          isfavorite: item.isfavorite,
          user: item.user
        ));
      });      
      model.data.ingredientsGroup.forEach((item) {
        initialIngredientsGroupDetail.add(
          IngredientsGroupDetail(
            uuid: item.uuid,
            body: item.body,
            ingredients: item.ingredients
          ));
      });
      model.data.steps.forEach((item) { 
        List<StepsDetailImages> initialStepsImagesDetail = [];
        for (int z = 0; z < 3; z++) {
          initialStepsImagesDetail.add(
            StepsDetailImages(
              uuid: item.stepsImages[z].uuid,
              body: item.stepsImages[z].body
            )
          );
        }
        initialStepsDetail.add(StepDetailData(
          uuid: item.uuid, 
          body: item.body,
          stepsImages: initialStepsImagesDetail
        ));
      });
      recipeDetail = initialRecipeDetail;
      ingredientsGroupDetail = initialIngredientsGroupDetail;
      stepsDetail = initialStepsDetail;
      favorite = model.data.recipes.first.isfavorite;
      notifyListeners();
    } catch(error) {
      print(error);
      throw error;
    }
  }
  
}