import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  int status;
  bool error;
  String message;
  List<UserData> data;

  UserModel({
    this.status,
    this.error,
    this.message,
    this.data,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: List<UserData>.from(json["data"].map((x) => UserData.fromJson(x))),
  );
}

class UserData with ChangeNotifier{
  int id;
  String uuid;
  String avatar;
  String name;
  String email;
  String bio;
  DateTime createdAt;
  DateTime updatedAt;
  
  UserData({
    this.id,
    this.uuid,
    this.name,
    this.email,
    this.createdAt,
    this.updatedAt,
    this.avatar,
    this.bio
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    id: json["id"],
    uuid: json["uuid"],
    avatar: json["avatar"],
    name: json["name"],
    email: json["email"],
    bio: json["bio"] == null ? "tidak ada bio" : json["bio"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );
}
