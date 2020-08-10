import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/Recipe.dart';
import '../constants/url.dart';
import '../constants/connection.dart';

class RecipeAdd with ChangeNotifier {
  RecipeAdd() {
    initState();
  }
  GlobalKey<FormState> formIngredientsKey = GlobalKey();
  GlobalKey<FormState> formStepsKey = GlobalKey();
  GlobalKey<FormState> formTitleKey = GlobalKey();
  ScrollController ingredientsScrollController = ScrollController();
  ScrollController stepsScrollController = ScrollController();
  int startSteps = 1;
  bool isLoading = false;
  FocusNode titleFocusNode = FocusNode();
  TextEditingController titleController = TextEditingController();
  List<Map<String, dynamic>> controllerIngredients = [];
  List<Map<String, dynamic>> controllerIngredientPerGroup = [];
  List<Map<String, dynamic>> controllerSteps = [];
  List<Map<String, dynamic>> focusIngredientsNode = [];
  List<Map<String, dynamic>> focusIngredientPerGroupNode = [];
  List<Map<String, dynamic>> focusStepsNode = [];
  List<IngredientsGroup> ingredientsGroup = [];
  List<Steps> steps = [];
  
  initState() {
    String ingredientUuidv4 = Uuid().v4();
    String ingredientInGroupUuidv4 = Uuid().v4();
    String stepUuidv4 = Uuid().v4();
    controllerIngredients.add({
      "uuid": ingredientUuidv4,
      "item": TextEditingController(text: "")
    });
    focusIngredientsNode.add({
      "uuid": ingredientUuidv4,
      "item": FocusNode()
    });
    controllerIngredientPerGroup.add({
      "uuid": ingredientInGroupUuidv4,
      "item": TextEditingController(text: "")
    });
    focusIngredientPerGroupNode.add({
      "uuid": ingredientInGroupUuidv4,
      "item": FocusNode()
    });
    controllerSteps.add({
      "uuid": stepUuidv4,
      "item": TextEditingController(text: "")
    });
    focusStepsNode.add({
      "uuid": stepUuidv4,
      "item": FocusNode()
    });
    ingredientsGroup.add(
      IngredientsGroup(
        uuid: ingredientInGroupUuidv4,
        ingredients: [
          Ingredients(
            uuid: ingredientUuidv4
          ),
        ]
      )
    );
    steps.add(Steps(
      uuid: stepUuidv4,
      images: [
        StepsImages(
          uuid: Uuid().v4(),
          body: CachedNetworkImage(
            width: 100.0,
            height: 100.0,
            imageUrl: '$imagesStepsUrl/default-image.png',
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          )
        ),
        StepsImages(
          uuid: Uuid().v4(),
          body: CachedNetworkImage(
            width: 100.0,
            height: 100.0,
            imageUrl: '$imagesStepsUrl/default-image.png',
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          )
        ),
        StepsImages(
          uuid: Uuid().v4(),
          body: CachedNetworkImage(
            width: 100.0,
            height: 100.0,
            imageUrl: '$imagesStepsUrl/default-image.png',
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          )
        ),
      ]
    ));
  }

  void incrementIngredientPerGroup() {
    Uuid uuid = Uuid();
    String uuidv4 = uuid.v4();
    ingredientsGroup.add(
      IngredientsGroup(
        uuid: uuidv4,
        ingredients: [
          Ingredients(
            uuid: uuidv4
          )
        ]
      )
    );
    focusIngredientPerGroupNode.add({
      "uuid": uuidv4,
      "item": FocusNode()
    });
    FocusNode nextNode = focusIngredientPerGroupNode[focusIngredientPerGroupNode.length-1]["item"];
    nextNode.requestFocus();
    controllerIngredientPerGroup.add({
      "uuid": uuidv4,
      "item": TextEditingController(text: "")
    });
    notifyListeners();
  }

  void decrementIngredientPerGroup(String uuid) {
    int existingIngredientPerGroup = ingredientsGroup.indexWhere((item) => item.uuid == uuid);
    int existingFocusIngredientPerGroupNode = focusIngredientPerGroupNode.indexWhere((item) => item["uuid"] == uuid);
    int existingControllerIngredientPerGroup = controllerIngredientPerGroup.indexWhere((item) => item["uuid"] == uuid);
    if(existingIngredientPerGroup >= 0) {
      ingredientsGroup.removeAt(existingIngredientPerGroup);
    }
    if(existingFocusIngredientPerGroupNode >= 0) {
      focusIngredientPerGroupNode.removeAt(existingFocusIngredientPerGroupNode);
    }
    if(existingControllerIngredientPerGroup >= 0) {
      controllerIngredientPerGroup.removeAt(existingControllerIngredientPerGroup);
    }
    notifyListeners();
  }

  void incrementIngredients(int i) {
    Uuid uuid = Uuid();
    String uuidv4 = uuid.v4();
    ingredientsGroup[i].ingredients.add(
      Ingredients(
        uuid: uuidv4,
      )
    );
    focusIngredientsNode.add({
      "uuid": uuidv4,
      "item": FocusNode()
    });
    FocusNode nextNode = focusIngredientsNode[focusIngredientsNode.length-1]["item"];
    nextNode.requestFocus();
    controllerIngredients.add({
      "uuid":  uuidv4,
      "item": TextEditingController(text: "")
    });
    notifyListeners();
  }

  void decrementIngredients(int i, String uuid) {
    int existingIngredientInGroup = ingredientsGroup[i].ingredients.indexWhere((item) => item.uuid == uuid);
    int existingFocusIngredientsNode = focusIngredientsNode.indexWhere((item) => item["uuid"] == uuid);
    int existingControllerIngredients = controllerIngredients.indexWhere((item) => item["uuid"] == uuid);
    if(existingIngredientInGroup >= 0) {
      ingredientsGroup[i].ingredients.removeAt(existingIngredientInGroup);
    }
    if(existingFocusIngredientsNode >= 0) {
      focusIngredientsNode.removeAt(existingFocusIngredientsNode);
    }
    if(existingControllerIngredients >= 0) {
      controllerIngredients.removeAt(existingControllerIngredients);
    }
    notifyListeners();
  }


  void incrementSteps() {

  }

  void decrementSteps() {
    
  }
  
  Future store(String title, String ingredients, String steps, String categoryId, String file) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, Object> extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
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
      final responseDecoded = json.decode(responseData);   
      notifyListeners();
      return responseDecoded;
    } catch(error) {
      print(error);
    }
  }
}