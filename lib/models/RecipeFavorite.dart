import 'package:flutter/material.dart';

class RecipeFavoriteModel with ChangeNotifier {
  int status;
  bool error;
  String message;
  List<RecipeFavoriteModelData> data;

  RecipeFavoriteModel({
    this.status,
    this.error,
    this.message,
    this.data,
  });

  factory RecipeFavoriteModel.fromJson(Map<String, dynamic> json) => RecipeFavoriteModel(
    status: json["status"] == null ? null : json["status"],
    error: json["error"] == null ? null : json["error"],
    message: json["message"] == null ? null : json["message"],
    data: json["data"] == null ? null : List<RecipeFavoriteModelData>.from(json["data"].map((x) => RecipeFavoriteModelData.fromJson(x))),
  );

}

class RecipeFavoriteModelData with ChangeNotifier {
  String uuid;
  String title;
  String imageUrl;
  String duration;
  String portion;
  int isfavorite;
  RecipeFavoriteModelDataUser user;
  RecipeFavoriteModelDataCategory category;
  RecipeFavoriteModelDataCountry country;

  RecipeFavoriteModelData({
    this.uuid,
    this.title,
    this.imageUrl,
    this.duration,
    this.isfavorite,
    this.portion,
    this.user,
    this.category,
    this.country
  });

  factory RecipeFavoriteModelData.fromJson(Map<String, dynamic> json) => RecipeFavoriteModelData(
    uuid: json["uuid"] == null ? null : json["uuid"],
    title: json["title"] == null ? null : json["title"],
    imageUrl: json["imageUrl"] == null ? null : json["imageUrl"],
    duration: json["duration"] == null ? null : json["duration"],
    portion:  json["portion"] == null ? null : json["portion"],
    isfavorite: json["isfavorite"] == null ? null : json["isfavorite"],
    user: RecipeFavoriteModelDataUser.fromJson(json["user"]),
    category: RecipeFavoriteModelDataCategory.fromJson(json["category"]),
    country: RecipeFavoriteModelDataCountry.fromJson(json["country"]),
  );
}

class RecipeFavoriteModelDataCategory {
  RecipeFavoriteModelDataCategory({
    this.title,
  });

  String title;

  factory RecipeFavoriteModelDataCategory.fromJson(Map<String, dynamic> json) => RecipeFavoriteModelDataCategory(
    title: json["title"],
  );
}

class RecipeFavoriteModelDataCountry {
  RecipeFavoriteModelDataCountry({
    this.name,
  });

  String name;

  factory RecipeFavoriteModelDataCountry.fromJson(Map<String, dynamic> json) => RecipeFavoriteModelDataCountry(
    name: json["name"],
  );
}

class RecipeFavoriteModelDataUser {
  RecipeFavoriteModelDataUser({
    this.uuid,
    this.name,
  });

  String uuid;
  String name;

  factory RecipeFavoriteModelDataUser.fromJson(Map<String, dynamic> json) => RecipeFavoriteModelDataUser(
    uuid: json["uuid"],
    name: json["name"],
  );
}
