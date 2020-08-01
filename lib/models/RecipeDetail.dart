import 'package:flutter/material.dart';

class RecipeDetailModel with ChangeNotifier {
  int status;
  bool error;
  String message;
  Data data;

  RecipeDetailModel({
    this.status,
    this.error,
    this.message,
    this.data,
  });

  factory RecipeDetailModel.fromJson(Map<String, dynamic> json) => RecipeDetailModel(
    status: json["status"] == null ? null : json["status"],
    error: json["error"] == null ? null : json["error"],
    message: json["message"] == null ? null : json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );
}

class Data with ChangeNotifier {
  List<RecipeDetailData> recipes;
  List<IngredientDetailData> ingredients;
  List<StepDetailData> steps;

  Data({
    this.recipes,
    this.ingredients,
    this.steps,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    recipes: json["recipes"] == null ? null : List<RecipeDetailData>.from(json["recipes"].map((x) => RecipeDetailData.fromJson(x))),
    ingredients: json["ingredients"] == null ? null : List<IngredientDetailData>.from(json["ingredients"].map((x) => IngredientDetailData.fromJson(x))),
    steps: json["steps"] == null ? null : List<StepDetailData>.from(json["steps"].map((x) => StepDetailData.fromJson(x))),
  );
}

class RecipeDetailData with ChangeNotifier {
  int id;
  String uuid;
  String title;
  String imageUrl;
  int isfavourite;

  RecipeDetailData({
    this.id,
    this.uuid,
    this.title,
    this.imageUrl,
    this.isfavourite
  });

  factory RecipeDetailData.fromJson(Map<String, dynamic> json) => RecipeDetailData(
    id: json["id"] == null ? null : json["id"],
    uuid: json["uuid"] == null ? null : json["uuid"],
    title: json["title"] == null ? null : json["title"],
    imageUrl: json["imageUrl"] == null ? null : json["imageUrl"],
    isfavourite: json["isfavourite"] == null ? null : json["isfavourite"]
  );
}

class IngredientDetailData with ChangeNotifier {
  String uuid;
  String body;

  IngredientDetailData({
    this.uuid,
    this.body,
  });

  factory IngredientDetailData.fromJson(Map<String, dynamic> json) => IngredientDetailData(
    uuid: json["uuid"] == null ? null : json["uuid"],
    body: json["body"] == null ? null : json["body"],
  );
}

class StepDetailData with ChangeNotifier {
  String uuid;
  String body;
  List<StepsDetailImages> stepsImages;
  StepDetailData({
    this.uuid,
    this.body,
    this.stepsImages
  });

  factory StepDetailData.fromJson(Map<String, dynamic> json) => StepDetailData(
    uuid: json["uuid"] == null ? null : json["uuid"],
    body: json["body"] == null ? null : json["body"],
    stepsImages: json["stepsImages"] == null ? null : List<StepsDetailImages>.from(json["stepsImages"].map((x) => StepsDetailImages.fromJson(x)))
  );
}

class StepsDetailImages {
  String uuid;
  String body;

  StepsDetailImages({
    this.uuid,
    this.body
  });

  factory StepsDetailImages.fromJson(Map<String, dynamic> json) => StepsDetailImages(
    uuid: json["uuid"] == null ? null : json["uuid"],
    body: json["body"] == null ? null : json["body"],
  );
}