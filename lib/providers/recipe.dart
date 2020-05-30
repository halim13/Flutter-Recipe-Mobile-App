import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/RecipeEdit.dart';

class Recipe extends ChangeNotifier {
  int ingredientsLength;
  int stepsLength;
  Data data;

  final GlobalKey<FormState> formIngredientsKey = GlobalKey();
  final GlobalKey<FormState> formStepsKey = GlobalKey();
  List<TextEditingController> listIngredientsController = [TextEditingController()];
  List<TextEditingController> listStepsController = [TextEditingController()];
  List<Map<String, Object>> valueIngredientsController = [];
  List<Map<String, Object>> valueStepsController = [];

  List<Recipes> get getRecipes => [...data.recipes];
  List<Ingredients> get getIngredients => [...data.ingredients];
  List<Steps> get getSteps => [...data.steps];

  Map<String, Object> indexRecipes(i) { 
    return valueIngredientsController.firstWhere((item) => item["idclone"] == getIngredients[i].id, orElse: () => null);
  }

  Map<String, Object> indexSteps(i) {
    return valueStepsController.firstWhere((item) => item["idclone"] == getSteps[i].id, orElse: null);
  }

  void incrementsIngredients() {
    ingredientsLength++;
    listIngredientsController.add(TextEditingController());
    notifyListeners();
  }
  void incrementsSteps() {
    stepsLength++;
    listStepsController.add(TextEditingController());
    notifyListeners();
  }
  void decrementIngredients(i) {
    ingredientsLength--;
    valueIngredientsController.removeWhere((element) => element["id"] == i);
    listIngredientsController.removeWhere((element) => element == listIngredientsController[i]);
    notifyListeners();
  }
  void decrementSteps(i) {
    stepsLength--;
    valueStepsController.removeWhere((element) => element["id"] == i);
    listStepsController.removeWhere((element) => element == listStepsController[i]);
    notifyListeners();
  }

  void updateBtn(String title, String mealId, File file, String categoryId) async {
    formIngredientsKey.currentState.save();
    formStepsKey.currentState.save();
    final seenIngredients = Set();
    final seenSteps = Set();
    final uniqueIngredients = valueIngredientsController.where((str) => seenIngredients.add(str["id"])).toList(); // Biar ngga duplicate
    final uniqueSteps = valueStepsController.where((str) => seenSteps.add(str["id"])).toList(); // Biar ngga duplicate
    final ingredients = jsonEncode(uniqueIngredients);
    final steps = jsonEncode(uniqueSteps);
    await update(title, mealId, file, ingredients, steps, categoryId);
  }

  Future edit(String mealId) async {
    String url = 'http://192.168.43.226:5000/api/v1/recipes/edit/$mealId'; // 192.168.43.85 || 10.0.2.2
    // wifi kantor 192.168.1.11
    // yang samsung 192.168.43.226
    try {
      http.Response response = await http.get(url);
      RecipeEditModel model = RecipeEditModel.fromJson(json.decode(response.body));
      data = model.data;
      ingredientsLength = getIngredients.length;
      stepsLength = getSteps.length;
      for (int i = 0; i < ingredientsLength; i++) {
        listIngredientsController[i].text = getIngredients[i].body;
        valueIngredientsController.add({
          "id": i,
          "idclone": getIngredients[i].id,
          "item": getIngredients[i].body
        });
        listIngredientsController.add(TextEditingController());
      }
      for (int i = 0; i < stepsLength; i++) {
        listStepsController[i].text = getSteps[i].body;
        valueStepsController.add({
          "id": i,
          "idclone": getSteps[i].id,
          "item": getSteps[i].body
        });
        listStepsController.add(TextEditingController());
      }
      notifyListeners();
    } catch(error) {
      print(error);
    }
  }

  Future store(String title, String ingredients, String steps, String categoryId, File file) async {
    final prefs = await SharedPreferences.getInstance();
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    String userId = extractedUserData["userId"];
    String url = 'http://192.168.43.226:5000/api/v1/recipes/store'; // 192.168.43.85 || 10.0.2.2
    // wifi kantor 192.168.1.11
    // yang samsung 192.168.43.226
    try {
      http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(url));
      http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
        'imageurl', file.path 
      );
      request.files.add(multipartFile);
      request.fields["title"] = title;
      request.fields["ingredients"] = ingredients;
      request.fields["steps"] = steps;
      request.fields["categoryId"] = categoryId;
      request.fields["userId"] = userId; 
      http.StreamedResponse response = await request.send();
      String responseData = await response.stream.bytesToString();
      final responseDataDecoded = json.decode(responseData);   
      notifyListeners();
      return responseDataDecoded;
    } catch(error) {
      print(error);
    }
  }

  Future update(String title, String mealId, File file, String ingredients, String steps, String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    String userId = extractedUserData["userId"];
    String url = 'http://192.168.43.226:5000/api/v1/recipes/update/$mealId'; // 192.168.43.85 || 10.0.2.2
    // wifi kantor 192.168.1.11
    // yang samsung 192.168.43.226
    // http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
    //   'imageurl', file.path 
    // );
    try {
      http.MultipartRequest request = http.MultipartRequest('PUT', Uri.parse(url));
      // request.files.add(multipartFile);
      request.fields["title"] = title;
      request.fields["ingredients"] = ingredients;
      request.fields["steps"] = steps;
      request.fields["categoryId"] = categoryId;
      request.fields["userId"] = userId; 
      http.StreamedResponse response = await request.send();
      String responseData = await response.stream.bytesToString();
      notifyListeners();
    } catch(error) {
      print(error);
    }
  }

}