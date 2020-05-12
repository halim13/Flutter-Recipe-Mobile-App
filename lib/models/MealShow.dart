import 'package:flutter/material.dart';

class MealShowModel with ChangeNotifier {
  int status;
  bool error;
  String message;
  List<MealShowData> data;

  MealShowModel({
    @required this.status,
    @required this.error,
    @required this.message,
    @required this.data,
  });

  factory MealShowModel.fromJson(Map<String, dynamic> json) => MealShowModel(
    status: json["status"] == null ? null : json["status"],
    error: json["error"] == null ? null : json["error"],
    message: json["message"] == null ? null : json["message"],
    data: json["data"] == null ? null : List<MealShowData>.from(json["data"].map((x) => MealShowData.fromJson(x))),
  );
}

class MealShowData with ChangeNotifier {
  String id;
  String title;
  int duration;
  String imageurl;
  String affordabilities;
  String complexities;

  MealShowData({
    @required this.id,
    @required this.title,
    @required this.duration,
    @required this.imageurl,
    @required this.affordabilities,
    @required this.complexities,
  });

  factory MealShowData.fromJson(Map<String, dynamic> json) => MealShowData(
    id: json["id"] == null ? null : json["id"],
    title: json["title"] == null ? null : json["title"],
    duration: json["duration"] == null ? null : json["duration"],
    imageurl: json["imageurl"] == null ? null : json["imageurl"],
    affordabilities: json["affordabilities"] == null ? null : json["affordabilities"],
    complexities: json["complexities"] == null ? null : json["complexities"],
  );
}