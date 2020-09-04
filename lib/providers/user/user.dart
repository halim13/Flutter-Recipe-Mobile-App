import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/connection.dart';
import '../../models/User.dart';

class User extends ChangeNotifier {
  bool isLoading = false;
  String isUserRecipeVal;
  
  List<UserData> currentProfile = [];
  List<UserData> viewProfile = [];
  List<UserData> get getCurrentProfileItem => [...currentProfile];
  List<UserData> get getViewProfileItem => [...viewProfile];

  bool get isUserRecipeCheck {
    return isUserRecipeVal != null;
  }

  Future<bool> isUserRecipe(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, Object> extractedUserData = json.decode(prefs.getString('userData'));
    String currentUserId = extractedUserData["userId"];
    if(userId == currentUserId) { 
      isUserRecipeVal = "true";
      notifyListeners();
    } else {
      isUserRecipeVal = null;
      notifyListeners();
    }
    return true;
  }

  Future<void> refreshProfile() async {
    await getCurrentProfile();
  }
  
  Future<void> getCurrentProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, Object> extractedUserData = json.decode(prefs.getString('userData'));
    String userId = extractedUserData["userId"];
    String url = 'http://$baseurl:$port/api/v1/accounts/users/profile/$userId'; 
    try {
      http.Response response = await http.get(url).timeout(Duration(seconds: 10));
      UserModel model = UserModel.fromJson(json.decode(response.body));
      List<UserData> initialProfile = [];
      model.data.forEach((item) {
        initialProfile.add(UserData(
          id: item.id,
          uuid: item.uuid,
          avatar: item.avatar,
          name: item.name,
          email: item.email,
          bio: item.bio,
          createdAt: item.createdAt,
          updatedAt: item.updatedAt
        ));
      }); 
      currentProfile = initialProfile;
      notifyListeners();
    } catch(error) {
      throw error;
    }
  }

  Future view(String userId) async {
    String url = 'http://$baseurl:$port/api/v1/accounts/users/profile/view/$userId';
    try {
      http.Response response = await http.get(url).timeout(Duration(seconds: 10));
      UserModel model = UserModel.fromJson(json.decode(response.body));
      List<UserData> initialViewProfile = [];
      model.data.forEach((item) {
        initialViewProfile.add(UserData(
          id: item.id,
          uuid: item.uuid,
          avatar: item.avatar,
          name: item.name,
          email: item.email,
          bio: item.bio,
          createdAt: item.createdAt,
          updatedAt: item.updatedAt
        ));
      }); 
      viewProfile = initialViewProfile;
      notifyListeners();
    } catch(error) {
      throw error;
    }
  }

  Future update(File file, String username, String bio) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, Object> extractedUserData = json.decode(prefs.getString('userData'));
    String userId = extractedUserData["userId"];
    Map<String, String> fields = {
      "username": username,
      "bio": bio
    };
    Map<String, String> headers = {"Content-Type": "application/json"};
    String url = 'http://$baseurl:$port/api/v1/accounts/users/profile/update/$userId';
    isLoading = true;
    notifyListeners();
    try {
      http.MultipartRequest request = http.MultipartRequest('PUT', Uri.parse(url));
      if(file != null) {
        http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
          'avatar', file.path
        );
        request.files.add(multipartFile);
      }
      request.headers.addAll(headers);
      request.fields.addAll(fields);
      http.StreamedResponse response = await request.send().timeout(Duration(seconds: 60));
      String responseData = await response.stream.bytesToString();
      final responseDecoded = json.decode(responseData);
      if(responseDecoded["status"] == 200) {
        refreshProfile();
        isLoading = false;
        notifyListeners();
      }
      notifyListeners();
      return responseDecoded;
    } catch(error) {
      print(error);
      throw error;
    }
  }

}
