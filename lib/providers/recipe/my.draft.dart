import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../constants/connection.dart';
import '../../constants/url.dart';
import '../../models/Recipe.dart';
import '../../models/RecipeDraft.dart';
import './detail.dart';
import './show.dart';

class MyDraft extends ChangeNotifier {

  Data data;
  File fileImageRecipe;
  String foodCountryName;
  String categoryName;
  String portionName;
  String getFileImageRecipe;
  String filenameImageRecipe;
  bool isLoading = false;
  String duration;
  ScrollController ingredientsScrollController = ScrollController();
  ScrollController stepsScrollController = ScrollController();
  FocusNode titleFocusNode = FocusNode();
  FocusNode portionFocusNode = FocusNode();

  TextEditingController titleController = TextEditingController();
  TextEditingController portionController = TextEditingController();
  List<String> categoriesDisplay = [""];
  List<String> foodCountriesDisplay = [""];
  List<String> portionsDisplay = ["1", "2", "3", "4", "5", "6", "7", "8"];
   
  List<Map<String, Object>> ingredientsGroupSendToHttp = [];
  List<Map<String, Object>> removeIngredientsGroupSendToHttp = [];
  List<Map<String, Object>> ingredientsSendToHttp = [];
  List<Map<String, Object>> removeIngredientsSendToHttp = [];
  List<Map<String, Object>> stepsSendToHttp = [];
  List<Map<String, Object>> removeStepsSendToHttp = [];
  
  List<RecipeDraftModelData> recipesDraft = [];
  List<IngredientsGroup> ingredientsGroup = [];
  List<Steps> steps = [];

  List<RecipeDraftModelData> get getRecipesDraftItem => [...recipesDraft];
  List<Recipes> get getRecipes => [...data.recipes];
  List<IngredientsGroup> get getIngredientsGroup => [...data.ingredientsGroup];
  List<Steps> get getSteps => [...data.steps];

  void changeImageRecipe(PickedFile pickedFile) {
    if(pickedFile != null) {
      fileImageRecipe = File(pickedFile.path);
      filenameImageRecipe = pickedFile.path;
      notifyListeners();
    }
  }

  void stepsImage(int i, int z, PickedFile pickedFile) async {  
    if(pickedFile != null) {
      steps[i].images[z].body = Image.file(File(pickedFile.path));
      steps[i].images[z].filename = pickedFile.path;
      notifyListeners();
    }
  }

  void incrementIngredientsPerGroup(BuildContext context) {
    Uuid uuid = Uuid();
    String uuidv4IngredientPerGroup = uuid.v4();
    String uuidv4Ingredients = uuid.v4();
    if(ingredientsGroup.length >= 10) {
      SnackBar snackbar = SnackBar(
        backgroundColor: Colors.yellow[300],
        content: Text('Maximum 10 Ingredients Group'),
        action: SnackBarAction(
          textColor: Colors.white,
          label: 'Close',
          onPressed: () {
            Scaffold.of(context).hideCurrentSnackBar();
          }
        ),
      );
      Scaffold.of(context).showSnackBar(snackbar);
    } else {
      ingredientsGroup.add(IngredientsGroup(
        uuid: uuidv4IngredientPerGroup,
        focusNode: FocusNode(),
        textEditingController: TextEditingController(text: ""),
        ingredients: [
          Ingredients(
            uuid: uuidv4Ingredients,
            focusNode: FocusNode(),
            textEditingController: TextEditingController(text: "")
          )
        ]
      ));  
      FocusNode nextNode = ingredientsGroup[ingredientsGroup.length-1].focusNode;
      nextNode.requestFocus();
    }
    notifyListeners();
  }

  void decrementIngredientsPerGroup(String uuid) {
    removeIngredientsGroupSendToHttp.add({
      "uuid": uuid
    });
    ingredientsGroup.removeWhere((item) => item.uuid == uuid);
    notifyListeners();
  }

  void incrementIngredients(BuildContext context, int i) {
    Uuid uuid = Uuid();
    String uuidv4 = uuid.v4();
    if(ingredientsGroup[i].ingredients.length >= 10) {
      SnackBar snackbar = SnackBar(
        backgroundColor: Colors.yellow[300],
        content: Text('Maximum 10 Ingredients'),
        action: SnackBarAction(
          textColor: Colors.white,
          label: 'Close',
          onPressed: () {
            Scaffold.of(context).hideCurrentSnackBar();
          }
        ),
      );
      Scaffold.of(context).showSnackBar(snackbar);
    } else {
      ingredientsGroup[i].ingredients.add(
        Ingredients(
          uuid: uuidv4,
          focusNode: FocusNode(),
          textEditingController: TextEditingController(text: "")
        )
      );
      FocusNode nextNode = ingredientsGroup[i].ingredients[ingredientsGroup[i].ingredients.length-1].focusNode;
      nextNode.requestFocus();
    }
    notifyListeners();
  }

  void decrementIngredients(int i, String uuid) {
    removeIngredientsSendToHttp.add({
      "uuid": uuid
    });
    ingredientsGroup[i].ingredients.removeWhere((item) => item.uuid == uuid);
    notifyListeners();
  }

  void incrementsSteps(BuildContext context) {
    Uuid uuid = Uuid();
    String uuid4 = uuid.v4(); 
    if(steps.length >= 10) {
      SnackBar snackbar = SnackBar(
        backgroundColor: Colors.red[300],
        content: Text('Maximum 10 Steps'),
        action: SnackBarAction(
          textColor: Colors.white,
          label: 'Close',
          onPressed: () {
            Scaffold.of(context).hideCurrentSnackBar();
          }
        ),
      );
      Scaffold.of(context).showSnackBar(snackbar);
    } else {
      steps.add(Steps(
        uuid: uuid4,
        focusNode: FocusNode(),
        textEditingController: TextEditingController(text: ""),
        images: [
          StepsImages(
            uuid: uuid.v4(),
            body: CachedNetworkImage(
              width: 100.0,
              height: 100.0,
              imageUrl: '$imagesStepsUrl/default-thumbnail.jpg',
              placeholder: (context, url) => Image.asset('assets/default-thumbnail.jpg'),
              errorWidget: (context, url, error) => Image.asset('assets/default-thumbnail.jpg'),
              fadeOutDuration: Duration(seconds: 1),
              fadeInDuration: Duration(seconds: 1),
            )
          ),
          StepsImages(
            uuid: uuid.v4(),
            body: CachedNetworkImage(
              width: 100.0,
              height: 100.0,
              imageUrl: '$imagesStepsUrl/default-thumbnail.jpg',
              placeholder: (context, url) => Image.asset('assets/default-thumbnail.jpg'),
              errorWidget: (context, url, error) => Image.asset('assets/default-thumbnail.jpg'),
              fadeOutDuration: Duration(seconds: 1),
              fadeInDuration: Duration(seconds: 1),
            )
          ),
          StepsImages(
            uuid: uuid.v4(),
            body: CachedNetworkImage(
              width: 100.0,
              height: 100.0,
              imageUrl: '$imagesStepsUrl/default-thumbnail.jpg',
              placeholder: (context, url) => Image.asset('assets/default-thumbnail.jpg'),
              errorWidget: (context, url, error) => Image.asset('assets/default-thumbnail.jpg'),
              fadeOutDuration: Duration(seconds: 1),
              fadeInDuration: Duration(seconds: 1),
            )
          )
        ]
      ));
      FocusNode nextNode = steps[steps.length-1].focusNode;
      nextNode.requestFocus();
    }
    notifyListeners();
  }

  void decrementSteps(String uuid) {
    removeStepsSendToHttp.add({
      "uuid": uuid
    });
    steps.removeWhere((element) => element.uuid == uuid);
    notifyListeners();
  }
  
  Future<void> edit(String recipeId) async {
    String url = 'http://$baseurl:$port/api/v1/recipes/edit/$recipeId'; 
    try {
      http.Response response = await http.get(url);
      RecipeModel model = RecipeModel.fromJson(json.decode(response.body));
      data = model.data;
      List<CategoryList> categories = data.recipes.first.categoryList;
      List<FoodCountryList> foodCountries = data.recipes.first.foodCountriesList;
      List<String> initialFoodCountriesDisplay = [];
      List<String> initialCategoriesDisplay = [];
      categories.forEach((item) {
        initialCategoriesDisplay.add(
          item.title,
        );
      });
      foodCountries.forEach((item) {
        initialFoodCountriesDisplay.add(
          item.name
        );
      });
      getFileImageRecipe = data.recipes.first.imageUrl;
      categoryName = data.recipes.first.categoryName;
      foodCountryName = data.recipes.first.foodCountryName;
      portionName = data.recipes.first.portion;
      categoriesDisplay = initialCategoriesDisplay;
      foodCountriesDisplay = initialFoodCountriesDisplay;
      duration = data.recipes.first.duration;
      titleController.text = data.recipes.first.title;
      portionController.text = data.recipes.first.portion;
      
      List<Steps> initialSteps = [];
      List<IngredientsGroup> initialIngredientsGroup = [];
      for(int i = 0; i < getIngredientsGroup.length; i++) {
        initialIngredientsGroup.add(IngredientsGroup(
          uuid: getIngredientsGroup[i].uuid,
          body: getIngredientsGroup[i].body,
          focusNode: FocusNode(),
          textEditingController: TextEditingController(text: getIngredientsGroup[i].body),
          ingredients: getIngredientsGroup[i].ingredients
        )); 
      }
      for(int k = 0; k < getSteps.length; k++) {
        List<StepsImages> initialStepsImages = [];
        Uuid uuid = Uuid();
        for (int j = 0; j < 3; j++) {
          final checkUuid = getSteps[k].images.asMap().containsKey(j) ? getSteps[k].images[j].uuid : uuid.v4();
          initialStepsImages.add(StepsImages(
            uuid: checkUuid,
            body: getSteps[k].images.asMap().containsKey(j) ? CachedNetworkImage(
              imageUrl: '$imagesStepsUrl/${getSteps[k].images[j].body}',
              placeholder: (context, url) => Image.asset('assets/default-thumbnail.jpg'),
              errorWidget: (context, url, error) => Image.asset('assets/default-thumbnail.jpg'),
              fadeOutDuration: Duration(seconds: 1),
              fadeInDuration: Duration(seconds: 1),
            ) : CachedNetworkImage(
              imageUrl: '$imagesStepsUrl/default-thumbnail.jpg',
              placeholder: (context, url) => Image.asset('assets/default-thumbnail.jpg'),
              errorWidget: (context, url, error) => Image.asset('assets/default-thumbnail.jpg'),
              fadeOutDuration: Duration(seconds: 1),
              fadeInDuration: Duration(seconds: 1),
            )
          ));
        }
        initialSteps.add(Steps(
          uuid: getSteps[k].uuid,
          body: getSteps[k].body,
          focusNode: FocusNode(),
          textEditingController: TextEditingController(text: getSteps[k].body),
          images: initialStepsImages
        ));
      }
      ingredientsGroup = initialIngredientsGroup;
      steps = initialSteps;
      notifyListeners();
    } catch(error) {
      print(error);
    }
  }

  Future update(
    BuildContext context,
    String title, 
    String recipeId, 
    String categoryId,
    String ingredientsGroup, 
    String removeIngredientsGroup, 
    String ingredients, 
    String removeIngredients, 
    String stepsParam, 
    String removeSteps, 
    String portion, 
    String categoryName
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    String userId = extractedUserData["userId"];
    Map<String, String> fields = {
      "title": title,
      "ingredients": ingredients,
      "removeIngredients": removeIngredients,
      "ingredientsGroup": ingredientsGroup,
      "removeIngredientsGroup": removeIngredientsGroup,
      "duration": duration,
      "steps": stepsParam,
      "removeSteps": removeSteps,
      "portion": portionName,
      "categoryName": categoryName,
      "foodCountryName": foodCountryName,
      "userId": userId
    };
    Map<String, String> headers = {"Content-Type": "application/json"};
    String url = 'http://$baseurl:$port/api/v1/recipes/update-draft/$recipeId';
    isLoading = true;
    notifyListeners();
    try {
      http.MultipartRequest request = http.MultipartRequest('PUT', Uri.parse(url));
      for (int i = 0; i < steps.length; i++) {
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
          'imageurl', filenameImageRecipe
        );
        request.files.add(multipartFile);
      }
      request.headers.addAll(headers);
      request.fields.addAll(fields);
      http.StreamedResponse response = await request.send().timeout(Duration(seconds: 60));
      if(response.statusCode == HttpStatus.ok) {
        isLoading = false;
        ingredientsGroupSendToHttp = [];
        removeIngredientsGroupSendToHttp = [];
        ingredientsSendToHttp = [];
        removeIngredientsSendToHttp = [];
        stepsSendToHttp = [];
        removeStepsSendToHttp = [];
        fileImageRecipe = null;
        if(categoryId != null) {
          Provider.of<RecipeShow>(context, listen: false).getShow(categoryId);
        }
        Provider.of<RecipeShow>(context, listen: false).suggestions();
        Provider.of<RecipeDetail>(context, listen: false).detail(recipeId);
        Provider.of<RecipeDetail>(context, listen: false).refreshRecipeFavorite();
        notifyListeners();
      } 
      String responseData = await response.stream.bytesToString();
      final responseDecoded = jsonDecode(responseData);   
      notifyListeners();  
      return responseDecoded;
    } catch(error) {
      print(error);
      throw error;
    }
  }

   Future<void> refreshRecipesDraft() async {
    await getRecipesDraft();
  }

  Future<void> getRecipesDraft([int limit = 0]) async {
    limit = limit + 5;
    String url = 'http://$baseurl:$port/api/v1/recipes/show-draft?limit=$limit'; 
    try {
      http.Response response = await http.get(url).timeout(Duration(seconds: 10));
      RecipeDraftModel model = RecipeDraftModel.fromJson(json.decode(response.body));
      List<RecipeDraftModelData> initialRecipesDraft = [];
      model.data.forEach((item) {
        initialRecipesDraft.add(RecipeDraftModelData(
          uuid: item.uuid,
          title: item.title,
          imageurl: item.imageurl,
          duration: item.duration,
          portion: item.portion,
          user: RecipeDraftModelDataUser(
            uuid: item.user.uuid,
            name: item.user.name
          ),
          category: RecipeDraftModelDataCategory(
            title: item.category.title
          ),
          country: RecipeDraftModelDataCountry(
            name: item.country.name
          )
        ));
      });
      recipesDraft = initialRecipesDraft;
      notifyListeners();
    } catch(error) {
      print(error);
      throw error;
    }
  }

}