import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constants/connection.dart';
import '../constants/url.dart';
import '../models/Recipe.dart';

class RecipeEdit extends ChangeNotifier {
  Data data;
  File fileImageRecipe;
  String categoryName;
  String getFileImageRecipe;
  String filenameImageRecipe;
  bool isLoadingEdited = false;
  ScrollController ingredientsScrollController = ScrollController();
  ScrollController stepsScrollController = ScrollController();
  FocusNode titleFocusNode = FocusNode();
  FocusNode ingredientsFocusNode = FocusNode();

  TextEditingController titleController = TextEditingController();
  GlobalKey<FormState> formTitleKey = GlobalKey();
  GlobalKey<FormState> formIngredientsKey = GlobalKey();
  GlobalKey<FormState> formStepsKey = GlobalKey();
  List<String> categoriesDisplay = [];
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

  void changeImageRecipe(PickedFile pickedFile) {
    if(pickedFile != null) {
      fileImageRecipe = File(pickedFile.path);
      filenameImageRecipe = pickedFile.path;
      notifyListeners();
    }
  }
  void stepsImage(int i, int z, PickedFile pickedFile) {  
    if(pickedFile != null) {
      steps[i].images[z].body = Image.file(File(pickedFile.path));
      steps[i].images[z].filename = pickedFile.path;
      notifyListeners();
    }
  }
  void incrementsIngredients() {
    Uuid uuid = Uuid();
    String uuid4 = uuid.v4();
    controllerIngredients.add({
      "uuid": uuid4,
      "item": TextEditingController(text: "")
    });
    focusIngredientsNode.add({
      "uuid": uuid4,
      "item": FocusNode()
    });
    ingredients.add(Ingredients(
      uuid: uuid4
    ));  
    FocusNode nextNode = focusIngredientsNode[focusIngredientsNode.length-1]["item"];
    nextNode.requestFocus();
    
    Future.delayed(Duration(milliseconds: 300), () {
      ingredientsScrollController.animateTo(
        ingredientsScrollController.position.maxScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    });
    notifyListeners();
  }
  void incrementsSteps() {
    Uuid uuid = Uuid();
    String uuid4 = uuid.v4(); 
    controllerSteps.add({
      "uuid": uuid4,
      "item": TextEditingController(text: "")
    });
    focusStepsNode.add({
      "uuid": uuid4,
      "item": FocusNode()
    });

    FocusNode nextNode = focusStepsNode[focusStepsNode.length-1]["item"];
    nextNode.requestFocus();

    Future.delayed(Duration(milliseconds: 300), () {
      stepsScrollController.animateTo(
        stepsScrollController.position.maxScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    });
    steps.add(Steps(
      uuid: uuid4,
      images: [
        StepsImages(
          uuid: uuid.v4(),
          body: CachedNetworkImage(
            width: 100.0,
            height: 100.0,
            imageUrl: '$imagesStepsUrl/default-image.png',
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          )
        ),
        StepsImages(
          uuid: uuid.v4(),
          body: CachedNetworkImage(
            width: 100.0,
            height: 100.0,
            imageUrl: '$imagesStepsUrl/default-image.png',
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          )
        ),
        StepsImages(
          uuid: uuid.v4(),
          body: CachedNetworkImage(
            width: 100.0,
            height: 100.0,
            imageUrl: '$imagesStepsUrl/default-image.png',
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          )
        )
      ]
    ));
    notifyListeners();
  }
  void decrementIngredients(String i) {
    valueIngredientsRemove.add({
      "uuid": i
    });    
    int existingIngredientsFocusNode = focusIngredientsNode.indexWhere((element) => element['uuid'] == i);
    int existingIngredients = ingredients.indexWhere((element) => element.uuid == i);
    int existingListIngredients = controllerIngredients.indexWhere((element) => element["uuid"] == i);
    if(existingIngredients >= 0) {
      ingredients.removeAt(existingIngredients);
    }
    if(existingIngredientsFocusNode >= 0) {
      focusIngredientsNode.removeAt(existingIngredientsFocusNode);
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
    int existingStepsFocusNode = focusStepsNode.indexWhere((element) => element["uuid"] == i);  
    int existingSteps = steps.indexWhere((element) => element.uuid == i);
    int existingListSteps = controllerSteps.indexWhere((element) => element["uuid"] == i);
    if(existingStepsFocusNode >= 0) {
      focusStepsNode.removeAt(existingStepsFocusNode);
    }
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
      RecipeModel model = RecipeModel.fromJson(json.decode(response.body));
      data = model.data;
      List<CategoryList> categories = data.recipes.first.categoryList;
      List<String> tempCategoriesDisplay = [];
      getFileImageRecipe = data.recipes.first.imageUrl;
      categories.forEach((element) {
        tempCategoriesDisplay.add(
          element.title,
        );
      });
      categoryName = data.recipes.first.categoryName;
      categoriesDisplay = tempCategoriesDisplay;
      titleController.text = data.recipes.first.title;
      List<Map<String, Object>> initialFocusIngredientsNode = [];
      List<Map<String, Object>> initialFocusStepsNode = [];
      List<Steps> initialSteps = [];
      List<Map<String, Object>> initialValueSteps = [];
      List<Map<String, Object>> initialControllerSteps = [];
      List<Ingredients> initialIngredients = [];
      List<Map<String, Object>> initialValueIngredients = [];
      List<Map<String, Object>> initialControllerIngredients = []; 
      getIngredients.forEach((item) {
        initialFocusIngredientsNode.add({
          "uuid": item.uuid,
          "item": FocusNode(canRequestFocus: true)
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
        Uuid uuid = Uuid();
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
          "item": FocusNode()
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
  Future update(String title, String recipeId, String ingredients, String stepsP, String removeIngredients, String removeSteps, String categoryName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    String userId = extractedUserData["userId"];
    String url = 'http://$baseurl:$port/api/v1/recipes/update/$recipeId'; 
    isLoadingEdited = true;
    notifyListeners();
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
      if(filenameImageRecipe != null) {
        http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
          'imagerecipe', filenameImageRecipe
        );
        request.files.add(multipartFile);
      }
      request.fields["title"] = title;
      request.fields["ingredients"] = ingredients;
      request.fields["steps"] = stepsP;
      request.fields["removeIngredients"] = removeIngredients;
      request.fields["removeSteps"] = removeSteps;
      request.fields["categoryName"] = categoryName;
      request.fields["userId"] = userId; 
      http.StreamedResponse response = await request.send();
      if(response.statusCode == 200) {
        isLoadingEdited = false;
        notifyListeners();
      }
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