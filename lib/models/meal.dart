import 'package:flutter/material.dart';

class MealShowModel with ChangeNotifier {
  int status;
  bool error;
  String message;
  List<MealShowData> data;

  MealShowModel({
    this.status,
    this.error,
    this.message,
    this.data,
  });

  factory MealShowModel.fromJson(Map<String, dynamic> json) => MealShowModel(
    status: json["status"] == null ? null : json["status"],
    error: json["error"] == null ? null : json["error"],
    message: json["message"] == null ? null : json["message"],
    data: json["data"] == null ? null : List<MealShowData>.from(json["data"].map((x) => MealShowData.fromJson(x))),
  );
}

class MealShowData with ChangeNotifier {
  String id;
  String title;
  int duration;
  String imageurl;
  String affordabilities;
  String complexities;

  MealShowData({
    this.id,
    this.title,
    this.duration,
    this.imageurl,
    this.affordabilities,
    this.complexities,
  });

  factory MealShowData.fromJson(Map<String, dynamic> json) => MealShowData(
    id: json["id"] == null ? null : json["id"],
    title: json["title"] == null ? null : json["title"],
    duration: json["duration"] == null ? null : json["duration"],
    imageurl: json["imageurl"] == null ? null : json["imageurl"],
    affordabilities: json["affordabilities"] == null ? null : json["affordabilities"],
    complexities: json["complexities"] == null ? null : json["complexities"],
  );
}

class MealDetailModel with ChangeNotifier {
  int status;
  bool error;
  String message;
  Data data;

  MealDetailModel({
    this.status,
    this.error,
    this.message,
    this.data,
  });

  factory MealDetailModel.fromJson(Map<String, dynamic> json) => MealDetailModel(
    status: json["status"] == null ? null : json["status"],
    error: json["error"] == null ? null : json["error"],
    message: json["message"] == null ? null : json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );
}

class Data with ChangeNotifier {
  List<MealDetailData> meals;
  List<IngredientDetailData> ingredients;
  List<StepDetailData> steps;

  Data({
    this.meals,
    this.ingredients,
    this.steps,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    meals: json["meals"] == null ? null : List<MealDetailData>.from(json["meals"].map((x) => MealDetailData.fromJson(x))),
    ingredients: json["ingredients"] == null ? null : List<IngredientDetailData>.from(json["ingredients"].map((x) => IngredientDetailData.fromJson(x))),
    steps: json["steps"] == null ? null : List<StepDetailData>.from(json["steps"].map((x) => StepDetailData.fromJson(x))),
  );
}

class MealDetailData with ChangeNotifier {
  String id;
  String title;
  String imageUrl;
  int isfavourite;

  MealDetailData({
    this.id,
    this.title,
    this.imageUrl,
    this.isfavourite
  });

  factory MealDetailData.fromJson(Map<String, dynamic> json) => MealDetailData(
    id: json["id"] == null ? null : json["id"],
    title: json["title"] == null ? null : json["title"],
    imageUrl: json["imageUrl"] == null ? null : json["imageUrl"],
    isfavourite: json["isfavourite"] == null ? null : json["isfavourite"]
  );
}

class IngredientDetailData with ChangeNotifier {
  String body;

  IngredientDetailData({
    this.body,
  });

  factory IngredientDetailData.fromJson(Map<String, dynamic> json) => IngredientDetailData(
    body: json["body"] == null ? null : json["body"],
  );
}

class StepDetailData with ChangeNotifier {
  String body;

  StepDetailData({
    this.body,
  });

  factory StepDetailData.fromJson(Map<String, dynamic> json) => StepDetailData(
    body: json["body"] == null ? null : json["body"],
  );

}

class MealsFavouriteModel with ChangeNotifier {
  int status;
  bool error;
  String message;
  List<MealsFavouriteData> data;

  MealsFavouriteModel({
    this.status,
    this.error,
    this.message,
    this.data,
  });

  factory MealsFavouriteModel.fromJson(Map<String, dynamic> json) => MealsFavouriteModel(
    status: json["status"] == null ? null : json["status"],
    error: json["error"] == null ? null : json["error"],
    message: json["message"] == null ? null : json["message"],
    data: json["data"] == null ? null : List<MealsFavouriteData>.from(json["data"].map((x) => MealsFavouriteData.fromJson(x))),
  );

}

class MealsFavouriteData with ChangeNotifier {
  String id;
  String title;
  int duration;
  int isfavourite;
  String affordability;
  String complexity;
  String imageUrl;

  MealsFavouriteData({
    this.id,
    this.title,
    this.duration,
    this.isfavourite,
    this.affordability,
    this.complexity,
    this.imageUrl,
  });

  factory MealsFavouriteData.fromJson(Map<String, dynamic> json) => MealsFavouriteData(
    id: json["id"] == null ? null : json["id"],
    title: json["title"] == null ? null : json["title"],
    duration: json["duration"] == null ? null : json["duration"],
    isfavourite: json["isfavourite"] == null ? null : json["isfavourite"],
    affordability: json["affordability"] == null ? null : json["affordability"],
    complexity: json["complexity"] == null ? null : json["complexity"],
    imageUrl: json["imageUrl"] == null ? null : json["imageUrl"],
  );

}
