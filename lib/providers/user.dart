import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/connection.dart';
import '../models/User.dart';

class User extends ChangeNotifier {
  String filename;
  File file;
  bool formEditUsername = false;
  bool formEditBio = false;
  bool isSaveChanges = false;
  DateTime uniqueAvatar =  DateTime.now();

  List<UserData> profile;
  List<UserData> get items => [...profile];

  bool isToggleSavedChanges() {
    if(isSaveChanges) {
      return true;
    } else {
      return false;
    }
  }
  bool isToggleFormEditUsername() {
    if(formEditUsername) {
      return true;
    } else {
      return false;
    }
  }
  bool isToggleFormEditBio() {
    if(formEditBio) {
      return true;
    } else {
      return false;
    }
  }

  void toggleSaveChanges() {
    isSaveChanges = !isSaveChanges;
    notifyListeners();
  }
  void toggleFormEditUsername() {
    formEditUsername = !formEditUsername;
    isSaveChanges = !isSaveChanges;
    notifyListeners();
  }
   void toggleFormEditBio() {
    formEditBio = !formEditBio;
    isSaveChanges = !isSaveChanges;
    notifyListeners();
  }
  void isCancelEditUser() {
    formEditUsername = false;
    formEditBio = false;
    isSaveChanges = false;
    file = null;
    notifyListeners();
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
      http.Response response = await http.get(url).timeout(Duration(seconds: 2));
      UserModel model = UserModel.fromJson(json.decode(response.body));
      List<UserData> loadedProfile = model.data; 
      profile = loadedProfile;
      notifyListeners();
    } catch(error) {
      throw error;
    }
  }
  Future update(String username, String bio) async {
    Map<String, String> fields = {
      "username": username,
      "bio": bio
    };
    Map<String, String> headers = {"Content-Type": "application/json"};
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, Object> extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    String userId = extractedUserData["userId"];
    String url = 'http://$baseurl:$port/api/v1/accounts/users/profile/update/$userId'; 
    try {
      http.MultipartRequest request = http.MultipartRequest('PUT', Uri.parse(url));
      if(file != null) {
        http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
          'avatar', filename
        );
        request.files.add(multipartFile);
      }
      request.headers.addAll(headers);
      request.fields.addAll(fields);
      http.StreamedResponse response = await request.send().timeout(Duration(seconds: 4));
      String responseData = await response.stream.bytesToString();
      final responseDataDecoded = json.decode(responseData);
      if(responseDataDecoded["status"] == 200) {
        if(file != null) {
          uniqueAvatar = DateTime.now();
          file = null;
        }
        refreshProfile();
      }
      formEditUsername = false;
      formEditBio = false;
      isSaveChanges = false;
      notifyListeners();
    } catch(error) {
      print(error);
      throw error;
    }
  }
}