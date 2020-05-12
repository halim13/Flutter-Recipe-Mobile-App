import 'package:flutter/material.dart';

class CategoryModel with ChangeNotifier {
  int status;
  bool error;
  String message;
  List<CategoryData> data;

  CategoryModel({
    @required this.status,
    @required this.error,
    @required this.message,
    @required this.data,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    status: json["status"] == null ? null : json["status"],
    error: json["error"] == null ? null : json["error"],
    message: json["message"] == null ? null : json["message"],
    data: json["data"] == null ? null : List<CategoryData>.from(json["data"].map((x) => CategoryData.fromJson(x))),
  );
}

class CategoryData with ChangeNotifier {
  String id;
  String title;
  String color;
  String cover;
  
  CategoryData({
    @required this.id,
    @required this.title,
    @required this.color,
    @required this.cover
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) => CategoryData(
    id: json["id"] == null ? null : json["id"],
    title: json["title"] == null ? null : json["title"],
    color: json["color"] == null ? null : json["color"],
    cover: json["cover"] == null ? null : json["cover"]
  );
}

