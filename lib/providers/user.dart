import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/User.dart';

class User extends ChangeNotifier {
  File file;
  bool formEditUsername = false;
  bool formEditBio = false;
  bool isSaveChanges = false;
  DateTime uniqueAvatar =  DateTime.now();

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

  List<UserData> profile;
  List<UserData> get items => [...profile];

  Future<void> getCurrentProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    String userId = extractedUserData["userId"];
    String url = 'http://192.168.43.226:5000/api/v1/accounts/users/profile/$userId'; // 192.168.43.85 || 10.0.2.2
    // wifi kantor 192.168.1.11
    // yang samsung 192.168.43.226
    try {
      http.Response response = await http.get(url);
      UserModel model = UserModel.fromJson(json.decode(response.body));
      List<UserData> loadedProfile = model.data; 
      profile = loadedProfile;
      notifyListeners();
    } catch(error) {
      throw error;
    }
  }

  Future<void> refreshProfile() async {
    await getCurrentProfile();
  }

  Future update(String username, String bio) async {
    final prefs = await SharedPreferences.getInstance();
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    String userId = extractedUserData["userId"];
    // String pathAvatar = 'http://192.168.43.85:5000/images/avatar';
    String url = 'http://192.168.43.226:5000/api/v1/accounts/users/profile/update/$userId'; // 192.168.43.85 || 10.0.2.2
    // wifi kantor 192.168.1.11
    // yang samsung 192.168.43.226
    try {
      http.MultipartRequest request = http.MultipartRequest('PUT', Uri.parse(url));
      if(file != null) {
        http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
          'avatar', file.path 
        );
        request.files.add(multipartFile);
      }
      request.fields['username'] = username;
      request.fields['bio'] = bio;
      http.StreamedResponse response = await request.send();
      String responseData = await response.stream.bytesToString();
      final responseDataDecoded = json.decode(responseData);
      if(responseDataDecoded["status"] == 200) {
        if(file != null) {
          // await DefaultCacheManager().removeFile('$pathAvatar/${profile[0].avatar}'); Gunakan jika menggunakan CacheNetworkImage
          uniqueAvatar = DateTime.now();
          file = null;
        }
        refreshProfile();
      }
      // Alternative aja
      // response.stream.transform(utf8.decoder).listen((value) async {
      //   final responseData = json.decode(value);
      //   if(responseData["status"] == 200) {
      //     if(file != null) {
      //       await DefaultCacheManager().removeFile('$pathAvatar/${profile[0].avatar}');
      //       await DefaultCacheManager().emptyCache();
      //       file = null;
      //     }
      //     refreshProfile();
      //   }
      // });
      formEditUsername = false;
      formEditBio = false;
      isSaveChanges = false;
      notifyListeners();
      return responseDataDecoded;
    } catch(error) {
      print(error);
      throw error;
    }
  }
}