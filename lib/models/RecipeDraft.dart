

import 'package:flutter/material.dart';

class RecipeDraftModel with ChangeNotifier {
  int status;
  bool error;
  String message;
  List<RecipeDraftModelData> data;

  
  RecipeDraftModel({
    this.status,
    this.error,
    this.message,
    this.data,
  });

  factory RecipeDraftModel.fromJson(Map<String, dynamic> json) => RecipeDraftModel(
    status: json["status"] == null ? null : json["status"],
    error: json["error"] == null ? null : json["error"],
    message: json["message"] == null ? null : json["message"],
    data: json["data"] == null ? null : List<RecipeDraftModelData>.from(json["data"].map((x) => RecipeDraftModelData.fromJson(x))),
  );
}

class RecipeDraftModelData with ChangeNotifier {
  String uuid;
  String title;
  String duration;
  String imageurl;
  String portion;
  int ispublished;
  RecipeDraftModelDataUser user;
  RecipeDraftModelDataCategory category;
  RecipeDraftModelDataCountry country;

  RecipeDraftModelData({
    this.uuid,
    this.title,
    this.duration,
    this.imageurl,
    this.portion,
    this.ispublished,
    this.user,
    this.category,
    this.country
  });

  factory RecipeDraftModelData.fromJson(Map<String, dynamic> json) => RecipeDraftModelData(
    uuid: json["uuid"] == null ? null : json["uuid"],
    title: json["title"] == null ? null : json["title"],
    duration: json["duration"] == null ? null : json["duration"],
    imageurl: json["imageurl"] == null ? null : json["imageurl"],
    portion: json["portion"] == null ? null : json["portion"],
    ispublished: json["ispublished"] == null ? null : json["ispublished"],
    user: RecipeDraftModelDataUser.fromJson(json["user"]),
    category: RecipeDraftModelDataCategory.fromJson(json["category"]),
    country: RecipeDraftModelDataCountry.fromJson(json["country"]),
  );
}

class RecipeDraftModelDataCategory {
  RecipeDraftModelDataCategory({
    this.title,
  });

  String title;

  factory RecipeDraftModelDataCategory.fromJson(Map<String, dynamic> json) => RecipeDraftModelDataCategory(
    title: json["title"],
  );
}

class RecipeDraftModelDataCountry {
  RecipeDraftModelDataCountry({
    this.name,
  });

  String name;

  factory RecipeDraftModelDataCountry.fromJson(Map<String, dynamic> json) => RecipeDraftModelDataCountry(
    name: json["name"],
  );
}

class RecipeDraftModelDataUser {
  RecipeDraftModelDataUser({
    this.uuid,
    this.name,
  });

  String uuid;
  String name;

  factory RecipeDraftModelDataUser.fromJson(Map<String, dynamic> json) => RecipeDraftModelDataUser(
    uuid: json["uuid"],
    name: json["name"],
  );
}
