import 'package:flutter/material.dart';

class FoodCountriesModel with ChangeNotifier {
  int status;
  bool error;
  String message;
  List<FoodCountriesData> data;

  FoodCountriesModel({
    this.status,
    this.error,
    this.message,
    this.data,
  });

  factory FoodCountriesModel.fromJson(Map<String, dynamic> json) => FoodCountriesModel(
    status: json["status"] == null ? null : json["status"],
    error: json["error"] == null ? null : json["error"],
    message: json["message"] == null ? null : json["message"],
    data: json["data"] == null ? null : List<FoodCountriesData>.from(json["data"].map((x) => FoodCountriesData.fromJson(x))),
  );
}

class CategoryModel with ChangeNotifier {
  int status;
  bool error;
  String message;
  List<CategoryData> data;

  CategoryModel({
    this.status,
    this.error,
    this.message,
    this.data,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    status: json["status"] == null ? null : json["status"],
    error: json["error"] == null ? null : json["error"],
    message: json["message"] == null ? null : json["message"],
    data: json["data"] == null ? null : List<CategoryData>.from(json["data"].map((x) => CategoryData.fromJson(x))),
  );
}

class CategoryData with ChangeNotifier {
  int id;
  String uuid;
  String title;
  String color;
  String cover;
  
  CategoryData({
    this.id,
    this.uuid,
    this.title,
    this.color,
    this.cover
  });

  static List<CategoryData> getCategoriesDropdown() {
    return <CategoryData>[
      CategoryData(
        uuid: 'none',
        title: 'Select a category'
      ),
      CategoryData(
        uuid: '054ba002-0122-496b-937e-32d05acef05c',
        title: 'Sayur'
      ),
      CategoryData(
        uuid: '66c76b29-2c1d-4e2a-9cb9-8ea855c57610',
        title: 'Daging'
      )
    ];
  }

  factory CategoryData.fromJson(Map<String, dynamic> json) => CategoryData(
    id: json["id"] == null ? null : json["id"],
    uuid: json["uuid"] == null ? null : json["uuid"],
    title: json["title"] == null ? null : json["title"],
    color: json["color"] == null ? null : json["color"],
    cover: json["cover"] == null ? null : json["cover"]
  );
}

class FoodCountriesData with ChangeNotifier {
  int id;
  String uuid;
  String name;

  FoodCountriesData({
    this.id, 
    this.uuid, 
    this.name
  });

  factory FoodCountriesData.fromJson(Map<String, dynamic> json) => FoodCountriesData(
    id: json["id"] == null ? null : json["id"],
    uuid: json["uuid"] == null ? null : json["uuid"],
    name: json["name"] == null ? null : json["name"],
  );
}

