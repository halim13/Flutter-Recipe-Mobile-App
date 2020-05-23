import 'package:flutter/material.dart';

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
  String id;
  String title;
  String color;
  String cover;
  
  CategoryData({
    @required this.id,
    @required this.title,
    this.color,
    this.cover
  });

  static List<CategoryData> getCategoriesDropdown() {
    return <CategoryData>[
      CategoryData(
        id: 'none',
        title: 'Select a category'
      ),
      CategoryData(
        id: '054ba002-0122-496b-937e-32d05acef05c',
        title: 'Sayur'
      ),
      CategoryData(
        id: '66c76b29-2c1d-4e2a-9cb9-8ea855c57610',
        title: 'Daging'
      )
    ];
  }

  factory CategoryData.fromJson(Map<String, dynamic> json) => CategoryData(
    id: json["id"] == null ? null : json["id"],
    title: json["title"] == null ? null : json["title"],
    color: json["color"] == null ? null : json["color"],
    cover: json["cover"] == null ? null : json["cover"]
  );
}

