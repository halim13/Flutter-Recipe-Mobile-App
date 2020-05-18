

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/User.dart';

class User extends ChangeNotifier {
  File file;
  bool formEditUsername = false;
  bool formEditEmail = false;
  bool isSaveChanges = false;

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
  bool isToggleFormEditEmail() {
    if(formEditEmail) {
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
  void toggleFormEditEmail() {
    formEditEmail = !formEditEmail;
    isSaveChanges = !isSaveChanges;
    notifyListeners();
  }
  void isCancelEditUser() {
    formEditUsername = false;
    formEditEmail = false;
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
    String url = 'http://192.168.43.85:5000/api/v1/accounts/users/profile/$userId'; // 192.168.43.85 || 10.0.2.2
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

  Future update(File avatar) async {
    final prefs = await SharedPreferences.getInstance();
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    String userId = extractedUserData["userId"];
    String pathAvatar = 'http://192.168.43.85:5000/images/avatar';
    String url = 'http://192.168.43.85:5000/api/v1/accounts/users/profile/update/$userId'; // 192.168.43.85 || 10.0.2.2
    try {
      http.MultipartRequest request = http.MultipartRequest('PUT', Uri.parse(url));
      http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
        'avatar', avatar.path,
      );
      request.files.add(multipartFile);
      http.StreamedResponse response = await request.send();
      response.stream.transform(utf8.decoder).listen((value) async {
        final responseData = json.decode(value);
        if(responseData["status"] == 200) {
          await DefaultCacheManager().removeFile('$pathAvatar/${profile[0].avatar}');
          refreshProfile();
        }
      });
      isSaveChanges = false;
      file = null;
      notifyListeners();
    } catch(error) {
      print(error);
      throw error;
    }
  }
}