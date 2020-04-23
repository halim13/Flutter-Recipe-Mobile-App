import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/Category.dart';

class Categories with ChangeNotifier {
  List<CategoryData> categories = [];
  List<CategoryData> get items {
    return[...categories];
  }

  Future<void> refreshProducts() async {
    await getCategories();
  }
  
  Future<void> getCategories() async {
    String url = 'http://192.168.43.85:5000/api/v1/categories'; // 192.168.43.85 || 10.0.2.2
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