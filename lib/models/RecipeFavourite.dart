import 'package:flutter/material.dart';

class RecipeFavouriteModel with ChangeNotifier {
  int status;
  bool error;
  String message;
  List<RecipeFavouriteData> data;

  RecipeFavouriteModel({
    this.status,
    this.error,
    this.message,
    this.data,
  });

  factory RecipeFavouriteModel.fromJson(Map<String, dynamic> json) => RecipeFavouriteModel(
    status: json["status"] == null ? null : json["status"],
    error: json["error"] == null ? null : json["error"],
    message: json["message"] == null ? null : json["message"],
    data: json["data"] == null ? null : List<RecipeFavouriteData>.from(json["data"].map((x) => RecipeFavouriteData.fromJson(x))),
  );

}

class RecipeFavouriteData with ChangeNotifier {
  int id;
  String uuid;
  String title;
  String duration;
  String portion;
  String name;
  int isfavourite;
  String imageUrl;

  RecipeFavouriteData({
    this.id,
    this.uuid,
    this.title,
    this.duration,
    this.portion,
    this.name,
    this.isfavourite,
    this.imageUrl,
  });

  factory RecipeFavouriteData.fromJson(Map<String, dynamic> json) => RecipeFavouriteData(
    id: json["id"] == null ? null : json["id"],
    uuid: json["uuid"] == null ? null : json["uuid"],
    title: json["title"] == null ? null : json["title"],
    duration: json["duration"] == null ? null : json["duration"],
    portion:  json["portion"] == null ? null : json["portion"],
    isfavourite: json["isfavourite"] == null ? null : json["isfavourite"],
    imageUrl: json["imageUrl"] == null ? null : json["imageUrl"],
    name: json["name"] == null ? null : json["name"]
  );
}
