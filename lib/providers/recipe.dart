import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constants/connection.dart';
import '../constants/url.dart';
import '../models/RecipeEdit.dart';

class Recipe extends ChangeNotifier {
  Data data;
  String path;
  FocusNode titleFocusNode = FocusNode();
  FocusNode ingredientsNode = FocusNode(); 
  FocusNode stepsNode = FocusNode();
  List<String> categoriesDisplay = [];
  String categoryName;
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

  void stepsImage(int i, int z, PickedFile pickedFile) async {  
    if(pickedFile != null) {
      steps[i].images[z].body = Image.file(File(pickedFile.path));
      steps[i].images[z].filename = pickedFile.path;
      notifyListeners();
    }
  }

  void incrementsIngredients() {
    Uuid uuid = new Uuid();
    String uuid4 = uuid.v4();
    controllerIngredients.add({
      "uuid": uuid4,
      "item": TextEditingController(text: "")
    });
    focusIngredientsNode.add({
      "uuid": uuid4,
      "item": FocusNode(canRequestFocus: true)
    });
    ingredients.add(Ingredients(
      uuid: uuid4
    ));
    notifyListeners();
  }
  void incrementsSteps() {
    Uuid uuid = new Uuid();
    String uuid4 = uuid.v4(); 
    controllerSteps.add({
      "uuid": uuid4,
      "item": TextEditingController(text: "")
    });
    focusStepsNode.add({
      "uuid": uuid4,
      "item": FocusNode(canRequestFocus: true)
    });
    steps.add(Steps(
      uuid: uuid4,
      images: [
        StepsImages(
          uuid: uuid.v4(),
          body: Image.network('$imagesStepsUrl/default-image.png', fit: BoxFit.fitHeight)
        ),
        StepsImages(
          uuid: uuid.v4(),
          body: Image.network('$imagesStepsUrl/default-image.png', fit: BoxFit.fitHeight)
        ),
        StepsImages(
          uuid: uuid.v4(),
          body: Image.network('$imagesStepsUrl/default-image.png', fit: BoxFit.fitHeight)
        )
      ]
    ));
    notifyListeners();
  }
  void decrementIngredients(String i) {
    valueIngredientsRemove.add({
      "uuid": i
    });    
    final existingIngredients = ingredients.indexWhere((element) => element.uuid == i);
    final existingListIngredients = controllerIngredients.indexWhere((element) => element["uuid"] == i);
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
      "uuid": i
    });    
    final existingSteps = steps.indexWhere((element) => element.uuid == i);
    final existingListSteps = controllerSteps.indexWhere((element) => element["uuid"] == i);
    if(existingSteps >= 0) {
      steps.removeAt(existingSteps);
    }
    if(existingListSteps >= 0) {
      controllerSteps.removeAt(existingListSteps);
    }
    notifyListeners();
  }

  Future edit(String recipeId) async {
    String url = 'http://$baseurl:$port/api/v1/recipes/edit/$recipeId'; 
    try {
      http.Response response = await http.get(url);
      RecipeEditModel model = RecipeEditModel.fromJson(json.decode(response.body));
      data = model.data;
      List<CategoryList> categories = data.recipes.first.categoryList;
      categoryName = data.recipes.first.categoryName;
      List<String> tempCategoriesDisplay = [];
      categories.forEach((element) {
        tempCategoriesDisplay.add(
          element.title,
        );
      });
      categoriesDisplay = tempCategoriesDisplay;
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
          "uuid": item.uuid,
          "item": ingredientsNode
        });
        initialFocusStepsNode.add({
          "uuid": item.uuid,
          "item": stepsNode
        });
        initialIngredients.add(Ingredients(
          uuid: item.uuid
        ));
        initialValueIngredients.add({
          "uuid": item.uuid,
          "uuidclone": item.uuid,
          "body": item.body 
        });
        initialControllerIngredients.add({
          "uuid": item.uuid,
          "item": TextEditingController(text: item.body)
        });
      });
      getSteps.asMap().forEach((i, item) {   
        List<StepsImages> initialStepsImages = [];
        Uuid uuid = new Uuid();
        for (int j = 0; j < 3; j++) {
          final checkUuid = getSteps[i].images.asMap().containsKey(j) ? getSteps[i].images[j].uuid : uuid.v4();
          final checkImage = getSteps[i].images.asMap().containsKey(j) ? '$imagesStepsUrl/${getSteps[i].images[j].body}' : '$imagesStepsUrl/default-image.png'; 
          initialStepsImages.add(StepsImages(
            uuid: checkUuid,
            body: CachedNetworkImage(
              width: 100.0,
              height: 100.0,
              imageUrl: checkImage,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            )
          ));
        }
        initialSteps.add(Steps(
          uuid: item.uuid,
          body: item.body,
          images: initialStepsImages
        ));
        initialValueSteps.add({
          "uuid": item.uuid,
          "body": item.body
        });
        initialFocusStepsNode.add({
          "uuid": item.uuid,
          "item": FocusNode(canRequestFocus: true)
        });
        initialControllerSteps.add({
          "uuid": item.uuid,
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
  Future store(String title, String ingredients, String steps, String categoryId, String file) async {
    final prefs = await SharedPreferences.getInstance();
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    String userId = extractedUserData["userId"];
    String url = 'http://$baseurl:$port/api/v1/recipes/store'; 
    try {
      http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(url));
      http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
        'imageurl', file 
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
  Future update(String title, String recipeId, String ingredients, String stepsP, String removeIngredients, String removeSteps, String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    String userId = extractedUserData["userId"];
    String url = 'http://$baseurl:$port/api/v1/recipes/update/$recipeId'; 
    try {
      http.MultipartRequest request = http.MultipartRequest('PUT', Uri.parse(url));
      for (int i = 0; i < steps.length; i++) {
        request.fields["stepsId$i"] = steps[i].uuid;
        for(int z = 0; z < steps[i].images.length; z++) {
          if(steps[i].images[z].filename != null) {
            request.fields["stepsImagesId-$i-$z"] = steps[i].images[z].uuid;
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
      edit(recipeId);
      DefaultCacheManager().emptyCache();
      notifyListeners();    
      return responseDecoded;
    } catch(error) {
      print(error);
    }
  }
}