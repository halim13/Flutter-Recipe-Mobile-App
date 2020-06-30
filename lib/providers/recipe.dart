import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constants/connection.dart';
import '../models/RecipeEdit.dart';
import 'package:image_picker/image_picker.dart';

class Recipe extends ChangeNotifier {
  Data data;
  PickedFile pickedFile;
  String path;
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
  List<Ingredients> ingredients = [];
  List<Ingredients> get getIngredients => [...data.ingredients];
  List<Steps> steps = [];
  List<Map<String, Object>> initialSteps = [];
  List<Steps> get getSteps => [...data.steps];

  void stepsImage(int i, int z) async {  
    steps[i].images[z].body = Image.file(File(pickedFile.path));
    steps[i].images[z].filename = pickedFile.path;
    // File imageFile = File(pickedFile.path);
    // List<int> imageBytes = await imageFile.readAsBytes();
    // String base64Image = base64Encode(imageBytes);
    // for(int g = 0; g < steps.length; g++) {
    //   steps[g].images.forEach((el) {
    //     initial.add({
    //       "id": steps[g].id,
    //       "item": path
    //     });
    //   });
    // }
    notifyListeners();
  }

  void incrementsIngredients() {
    Uuid uuid = new Uuid();
    String uuid4 = uuid.v4();
    controllerIngredients.add({
      "id": uuid4,
      "item": TextEditingController(text: "")
    });
    focusIngredientsNode.add({
      "id": uuid4,
      "item": FocusNode(canRequestFocus: true)
    });
    ingredients.add(Ingredients(
      id: uuid4
    ));
    notifyListeners();
  }
  void incrementsSteps() {
    Uuid uuid = new Uuid();
    String uuid4 = uuid.v4();
    controllerSteps.add({
      "id": uuid4,
      "item": TextEditingController(text: "")
    });
    focusStepsNode.add({
      "id": uuid4,
      "item": FocusNode(canRequestFocus: true)
    });
    steps.add(Steps(
      id: uuid4
    ));
    notifyListeners();
  }
  void decrementIngredients(String i) {
    valueIngredientsRemove.add({
      "id": i
    });    
    final existingIngredients = ingredients.indexWhere((element) => element.id == i);
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
    final existingSteps = steps.indexWhere((element) => element.id == i);
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
      final List<Steps> initialSteps = [];
      final List<Map<String, Object>> initialValueSteps = [];
      final List<Map<String, Object>> initialControllerSteps = [];
      List<Ingredients> initialIngredients = [];
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
        initialIngredients.add(Ingredients(
          id: item.id
        ));
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
      getSteps.asMap().forEach((i, item) {
        List<StepsImages> tests = [];
        item.images.asMap().forEach((i, item) {
          tests.add(StepsImages(
            id: item.id,
            body: Image.network('$imagesStepsUrl/${item.body}')
          ));
        });
        initialSteps.add(Steps(
          id: item.id,
          body: item.body,
          images: tests  
        ));
        initialValueSteps.add({
          "id": item.id,
          "idclone": item.id,
          "body": item.body
        });
        initialFocusStepsNode.add({
          "id": item.id,
          "item": FocusNode(canRequestFocus: true)
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

  Future update(String title, String mealId, String ingredients, String stepsP, String removeIngredients, String removeSteps, String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    String userId = extractedUserData["userId"];
    String url = 'http://$baseurl:$port/api/v1/recipes/update/$mealId'; 
    try {
      http.MultipartRequest request = http.MultipartRequest('PUT', Uri.parse(url));
      for (int i = 0; i < steps.length; i++) {
        request.fields["stepsId$i"] = steps[i].id;
        for(int z = 0; z < steps[i].images.length; z++) {
          if( steps[i].images[z].filename != null) {
            http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
              'imageurl-$i-$z', steps[i].images[z].filename
            );
            request.files.add(multipartFile);
          }
        }
      }
      request.fields["title"] = title;
      request.fields["ingredients"] = ingredients;
      request.fields["steps"] = stepsP;
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