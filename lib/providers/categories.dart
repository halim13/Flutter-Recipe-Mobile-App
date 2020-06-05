import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/connection.dart';
import '../models/Category.dart';

class Categories with ChangeNotifier {
  List<CategoryData> categories = [];
  List<CategoryData> get items => [...categories];
  
  Future<void> refreshProducts() async {
    await getCategories();
  }
  
  Future<void> getCategories() async {
    String url = 'http://$baseurl:$port/api/v1/categories'; // 192.168.43.85 || 10.0.2.2 
    // wifi kantor 192.168.1.11
    // yang samsung 192.168.43.226
    try {
      http.Response response = await http.get(url);
      CategoryModel model = CategoryModel.fromJson(json.decode(response.body));
      List<CategoryData> loadedCategories = model.data; 
      categories = loadedCategories;
      notifyListeners();
    } catch(error) {
      throw error;
    }
  }
}