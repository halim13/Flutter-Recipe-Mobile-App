import 'package:flutter/material.dart';

class RecipeShowModel with ChangeNotifier {
  int status;
  bool error;
  String message;
  List<RecipeShowData> data;

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
    data: json["data"] == null ? null : List<RecipeShowData>.from(json["data"].map((x) => RecipeShowData.fromJson(x))),
  );
}

class RecipeShowData with ChangeNotifier {
  int id;
  String uuid;
  String title;
  String duration;
  String imageurl;
  String portion;
  String name;

  RecipeShowData({
    this.id,
    this.uuid,
    this.title,
    this.duration,
    this.imageurl,
    this.portion,
    this.name
  });

  factory RecipeShowData.fromJson(Map<String, dynamic> json) => RecipeShowData(
    id: json["id"] == null ? null : json["id"],
    uuid: json["uuid"] == null ? null : json["uuid"],
    title: json["title"] == null ? null : json["title"],
    duration: json["duration"] == null ? null : json["duration"],
    imageurl: json["imageurl"] == null ? null : json["imageurl"],
    portion: json["portion"] == null ? null : json["portion"],
    name: json["name"] == null ? null : json["name"]
  );
}