import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/connection.dart';
import '../models/User.dart';

class User extends ChangeNotifier {
  bool isLoading = false;

  List<UserData> profile;
  List<UserData> get items => [...profile];

  Future<void> refreshProfile() async {
    await getCurrentProfile();
  }
   Future<void> getCurrentProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, Object> extractedUserData = json.decode(prefs.getString('userData'));
    String userId = extractedUserData["userId"];
    String url = 'http://$baseurl:$port/api/v1/accounts/users/profile/$userId'; 
    try {
      http.Response response = await http.get(url).timeout(Duration(seconds: 2));
      UserModel model = UserModel.fromJson(json.decode(response.body));
      List<UserData> loadedProfile = model.data; 
      profile = loadedProfile;
      notifyListeners();
    } catch(error) {
      throw error;
    }
  }
  Future update(File file, String username, String bio) async {
    Map<String, String> fields = {
      "username": username,
      "bio": bio
    };
    Map<String, String> headers = {"Content-Type": "application/json"};
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, Object> extractedUserData = json.decode(prefs.getString('userData'));
    String userId = extractedUserData["userId"];
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
      http.StreamedResponse response = await request.send().timeout(Duration(seconds: 4));
      String responseData = await response.stream.bytesToString();
      final responseDataDecoded = json.decode(responseData);
      if(responseDataDecoded["status"] == 200) {
        refreshProfile();
        isLoading = false;
        notifyListeners();
      }
      notifyListeners();
    } catch(error) {
      print(error);
      throw error;
    }
  }
}