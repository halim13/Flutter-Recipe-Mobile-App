import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constants/connection.dart';
import '../models/RecipeEdit.dart';

class Recipe extends ChangeNotifier {
  Data data;
  FocusNode titleFocusNode = FocusNode();
  FocusNode ingredientsNode = FocusNode(); 
  FocusNode stepsNode = FocusNode();
  final TextEditingController titleController = TextEditingController();
  final GlobalKey<FormState> formTitleKey = GlobalKey();
  final GlobalKey<FormState> formIngredientsKey = GlobalKey();
  final GlobalKey<FormState> formStepsKey = GlobalKey();
  List<Map<String, Object>> focusIngredientsNode = [];
  List<Map<String, Object>> focusStepsNode = [];
  List<Map<String, Object>> controllerIngredients = [];
  List<Map<String, Object>> controllerSteps = [];
  List<Map<String, Object>> valueIngredients = [];
  List<Map<String, Object>> valueSteps = [];
  List<Map<String, Object>> valueIngredientsRemove = []; 
  List<Map<String, Object>> valueStepsRemove = [];

  List<Recipes> get getRecipes => [...data.recipes];
  List<Map<String, Object>> initialIngredients = [];
  List<Map<String, Object>> ingredients = [];
  List<Ingredients> get getIngredients => [...data.ingredients];
  List<Map<String, Object>> steps = [];
  List<Map<String, Object>> initialSteps = [];
  List<Steps> get getSteps => [...data.steps];

  void incrementsIngredients() {
    Uuid uuid = new Uuid();
    String uuid4 = uuid.v4();
    controllerIngredients.add({
      "id": uuid4,
      "item": TextEditingController(text: "Contoh: 1 Cabe Merah")
    });
    focusIngredientsNode.add({
      "id": uuid4,
      "item": FocusNode(canRequestFocus: true)
    });
    ingredients.add({
      "id": uuid4
    });
    notifyListeners();
  }
  void incrementsSteps() {
    Uuid uuid = new Uuid();
    String uuid4 = uuid.v4();
    controllerSteps.add({
      "id": uuid4,
      "item": TextEditingController(text: "Contoh: Iris Cabe dengan Pisau")
    });
    focusStepsNode.add({
      "id": uuid4,
      "item": FocusNode(canRequestFocus: true)
    });
    steps.add({
      "id": uuid4
    });
    notifyListeners();
  }
  void decrementIngredients(String i) {
    valueIngredientsRemove.add({
      "id": i
    });    
    final existingIngredients = ingredients.indexWhere((element) => element["id"] == i);
    final existingListIngredients = controllerIngredients.indexWhere((element) => element["id"] == i);
    if(existingIngredients >= 0) {
      ingredients.removeAt(existingIngredients);
    }
    if(existingListIngredients >= 0) {
      controllerIngredients.removeAt(existingListIngredients);
    }
    notifyListeners();
  }
  void decrementSteps(String i) {
   valueStepsRemove.add({
      "id": i
    });    
    final existingSteps = steps.indexWhere((element) => element["id"] == i);
    final existingListSteps = controllerSteps.indexWhere((element) => element["id"] == i);
    if(existingSteps >= 0) {
      steps.removeAt(existingSteps);
    }
    if(existingListSteps >= 0) {
      controllerSteps.removeAt(existingListSteps);
    }
    notifyListeners();
  }

  Future edit(String mealId) async {
    String url = 'http://$baseurl:$port/api/v1/recipes/edit/$mealId'; 
    try {
      http.Response response = await http.get(url);
      RecipeEditModel model = RecipeEditModel.fromJson(json.decode(response.body));
      data = model.data;
      titleController.text = data.recipes.first.title;
      final List<Map<String, Object>> initialFocusIngredientsNode = [];
      final List<Map<String, Object>> initialFocusStepsNode = [];
      final List<Map<String, Object>> initialSteps = [];
      final List<Map<String, Object>> initialValueSteps = [];
      final List<Map<String, Object>> initialControllerSteps = [];
      final List<Map<String, Object>> initialIngredients = [];
      final List<Map<String, Object>> initialValueIngredients = [];
      final List<Map<String, Object>> initialControllerIngredients = []; 
      getIngredients.forEach((item) {
        initialFocusIngredientsNode.add({
          "id": item.id,
          "item": ingredientsNode
        });
        initialFocusStepsNode.add({
          "id": item.id,
          "item": stepsNode
        });
        initialIngredients.add({
          "id": item.id
        });
        initialValueIngredients.add({
          "id": item.id,
          "idclone": item.id,
          "body": item.body 
        });
        initialControllerIngredients.add({
          "id": item.id,
          "item": TextEditingController(text: item.body)
        });
      });
      getSteps.forEach((item) {
        initialSteps.add({
          "id": item.id
        });
        initialValueSteps.add({
          "id": item.id,
          "idclone": item.id,
          "body": item.body
        });
        initialControllerSteps.add({
          "id": item.id,
          "item": TextEditingController(text: item.body)
        });
      });
      focusIngredientsNode = initialFocusIngredientsNode;
      focusStepsNode = initialFocusStepsNode;
      ingredients = initialIngredients;
      steps = initialSteps;
      valueIngredients = initialValueIngredients;
      valueSteps = initialValueSteps;
      controllerIngredients = initialControllerIngredients;
      controllerSteps = initialControllerSteps;
      notifyListeners();
    } catch(error) {
      print(error);
    }
  }

  Future store(String title, String ingredients, String steps, String categoryId, File file) async {
    final prefs = await SharedPreferences.getInstance();
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    String userId = extractedUserData["userId"];
    String url = 'http://$baseurl:$port/api/v1/recipes/store'; 
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

  Future update(String title, String mealId, File file, String ingredients, String steps, String removeIngredients, String removeSteps, String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    String userId = extractedUserData["userId"];
    String url = 'http://$baseurl:$port/api/v1/recipes/update/$mealId'; 
    // http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
    //   'imageurl', file.path 
    // );
    try {
      http.MultipartRequest request = http.MultipartRequest('PUT', Uri.parse(url));
      // request.files.add(multipartFile);
      request.fields["title"] = title;
      request.fields["ingredients"] = ingredients;
      request.fields["steps"] = steps;
      request.fields["removeIngredients"] = removeIngredients;
      request.fields["removeSteps"] = removeSteps;
      request.fields["categoryId"] = categoryId;
      request.fields["userId"] = userId; 
      http.StreamedResponse response = await request.send();
      String responseData = await response.stream.bytesToString();
      final responseDecoded = jsonDecode(responseData);
      notifyListeners();    
      return responseDecoded;
    } catch(error) {
      print(error);
    }
  }
}