import 'package:flutter/material.dart';

class MealDetailModel with ChangeNotifier {
  int status;
  bool error;
  String message;
  Data data;

  MealDetailModel({
    @required this.status,
    @required this.error,
    @required this.message,
    @required this.data,
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
    @required this.meals,
    @required this.ingredients,
    @required this.steps,
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
    @required this.id,
    @required this.title,
    @required this.imageUrl,
    @required this.isfavourite
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
    @required this.body,
  });

  factory IngredientDetailData.fromJson(Map<String, dynamic> json) => IngredientDetailData(
    body: json["body"] == null ? null : json["body"],
  );
}

class StepDetailData with ChangeNotifier {
  String body;

  StepDetailData({
    @required this.body,
  });

  factory StepDetailData.fromJson(Map<String, dynamic> json) => StepDetailData(
    body: json["body"] == null ? null : json["body"],
  );
}