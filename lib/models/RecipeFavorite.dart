import 'package:flutter/material.dart';

class RecipeFavoriteModel with ChangeNotifier {
  int status;
  bool error;
  String message;
  List<RecipeFavoriteData> data;

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
    data: json["data"] == null ? null : List<RecipeFavoriteData>.from(json["data"].map((x) => RecipeFavoriteData.fromJson(x))),
  );

}

class RecipeFavoriteData with ChangeNotifier {
  int id;
  String uuid;
  String title;
  String duration;
  String portion;
  String name;
  int isfavorite;
  String userId;
  String imageUrl;

  RecipeFavoriteData({
    this.id,
    this.uuid,
    this.title,
    this.imageUrl,
    this.duration,
    this.isfavorite,
    this.portion,
    this.userId,
    this.name,
  });

  factory RecipeFavoriteData.fromJson(Map<String, dynamic> json) => RecipeFavoriteData(
    id: json["id"] == null ? null : json["id"],
    uuid: json["uuid"] == null ? null : json["uuid"],
    title: json["title"] == null ? null : json["title"],
    duration: json["duration"] == null ? null : json["duration"],
    portion:  json["portion"] == null ? null : json["portion"],
    isfavorite: json["isfavorite"] == null ? null : json["isfavorite"],
    imageUrl: json["imageUrl"] == null ? null : json["imageUrl"],
    userId: json["user_id"] == null ? null : json["user_id"],
    name: json["name"] == null ? null : json["name"]
  );
}
