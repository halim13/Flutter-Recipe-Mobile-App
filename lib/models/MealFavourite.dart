import 'package:flutter/material.dart';

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
