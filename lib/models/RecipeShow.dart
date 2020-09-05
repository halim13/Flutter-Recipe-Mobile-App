import 'package:flutter/material.dart';

class RecipeShowModel with ChangeNotifier {
  int status;
  bool error;
  String message;
  List<RecipeShowModelData> data;

  RecipeShowModel({
    this.status,
    this.error,
    this.message,
    this.data,
  });

  factory RecipeShowModel.fromJson(Map<String, dynamic> json) => RecipeShowModel(
    status: json["status"] == null ? null : json["status"],
    error: json["error"] == null ? null : json["error"],
    message: json["message"] == null ? null : json["message"],
    data: json["data"] == null ? null : List<RecipeShowModelData>.from(json["data"].map((x) => RecipeShowModelData.fromJson(x))),
  );
}

class RecipeShowModelData with ChangeNotifier {
  String uuid;
  String title;
  String duration;
  String imageurl;
  String portion;
  RecipeShowModelDataUser user;
  RecipeShowModelDataCategory category;
  RecipeShowModelDataCountry country;


  RecipeShowModelData({
    this.uuid,
    this.title,
    this.duration,
    this.imageurl,
    this.portion,
    this.user,
    this.category,
    this.country
  });

  factory RecipeShowModelData.fromJson(Map<String, dynamic> json) => RecipeShowModelData(
    uuid: json["uuid"] == null ? null : json["uuid"],
    title: json["title"] == null ? null : json["title"],
    duration: json["duration"] == null ? null : json["duration"],
    imageurl: json["imageurl"] == null ? null : json["imageurl"],
    portion: json["portion"] == null ? null : json["portion"],
    user: RecipeShowModelDataUser.fromJson(json["user"]),
    category: RecipeShowModelDataCategory.fromJson(json["category"]),
    country: RecipeShowModelDataCountry.fromJson(json["country"]),
  );
}

class RecipeShowModelDataCategory {
  RecipeShowModelDataCategory({
    this.title,
  });

  String title;

  factory RecipeShowModelDataCategory.fromJson(Map<String, dynamic> json) => RecipeShowModelDataCategory(
    title: json["title"],
  );
}

class RecipeShowModelDataCountry {
  RecipeShowModelDataCountry({
    this.name,
  });

  String name;

  factory RecipeShowModelDataCountry.fromJson(Map<String, dynamic> json) => RecipeShowModelDataCountry(
    name: json["name"],
  );
}

class RecipeShowModelDataUser {
  RecipeShowModelDataUser({
    this.uuid,
    this.name,
  });

  String uuid;
  String name;

  factory RecipeShowModelDataUser.fromJson(Map<String, dynamic> json) => RecipeShowModelDataUser(
    uuid: json["uuid"],
    name: json["name"],
  );
}