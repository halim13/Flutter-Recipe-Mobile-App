import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
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

  List<RecipeFavoriteModelData> displayRecipeFavorite = [];

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
      List<RecipeFavoriteModelData> initialDisplayRecipeFavorite = [];
      model.data.forEach((item) {
        initialDisplayRecipeFavorite.add(
         RecipeFavoriteModelData(
            uuid: item.uuid,
            title: item.title,
            imageUrl: item.imageUrl,
            duration: item.duration,
            portion: item.portion,
            isfavorite: item.isfavorite,
            user: RecipeFavoriteModelDataUser(
              uuid: item.user.uuid,
              name: item.user.name
            ),
            category: RecipeFavoriteModelDataCategory(
              title: item.category.title
            ), 
            country: RecipeFavoriteModelDataCountry(
              name: item.country.name
            )
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
          user: RecipeDetailDataUser(
            uuid: item.user.uuid,
            name: item.user.name
          ),
          category: RecipeDetailDataCategory(
            title: item.category.title
          ), 
          country: RecipeDetailDataCountry(
            name: item.country.name
          )
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
      for(int i = 0; i < model.data.steps.length; i++) {
        List<StepsDetailImages> initialStepsImagesDetail = [];
        Uuid uuid = Uuid();
        for (int z = 0; z < 3; z++) {
          final checkUuid = model.data.steps[i].stepsImages.asMap().containsKey(z) ? model.data.steps[i].stepsImages[z].uuid : uuid.v4();
          initialStepsImagesDetail.add(StepsDetailImages(
              uuid: checkUuid,
              body: model.data.steps[i].stepsImages.asMap().containsKey(z) 
              ? '${model.data.steps[i].stepsImages[z].body}'
              : 'default-thumbnail.jpg'
              // ? CachedNetworkImage(
              //   imageUrl: '$imagesStepsUrl/${model.data.steps[i].stepsImages[z].body}',
              //   placeholder: (context, url) => Image.asset('assets/default-thumbnail.jpg'),
              //   errorWidget: (context, url, error) => Image.asset('assets/default-thumbnail.jpg'),
              //   fadeOutDuration: Duration(seconds: 1),
              //   fadeInDuration: Duration(seconds: 1),
              // ) : CachedNetworkImage(
              //   imageUrl: '$imagesStepsUrl/default-thumbnail.jpg',
              //   placeholder: (context, url) => Image.asset('assets/default-thumbnail.jpg'),
              //   errorWidget: (context, url, error) => Image.asset('assets/default-thumbnail.jpg'),
              //   fadeOutDuration: Duration(seconds: 1),
              //   fadeInDuration: Duration(seconds: 1),
              // )
          ));
        }
        initialStepsDetail.add(StepDetailData(
          uuid: model.data.steps[i].uuid, 
          body: model.data.steps[i].body,
          stepsImages: initialStepsImagesDetail
        ));
      }
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