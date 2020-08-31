import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../models/Category.dart';
import '../../models/Recipe.dart';
import '../../constants/url.dart';
import '../../constants/connection.dart';

class RecipeAdd with ChangeNotifier {

  RecipeAdd() {
    initState();
  }
  GlobalKey<FormState> formTitleKey = GlobalKey();
  ScrollController ingredientsScrollController = ScrollController();
  ScrollController stepsScrollController = ScrollController();
  bool isLoading = false;
  File fileImageRecipe;
  String filenameImageRecipe;
  String categoryName = "";
  List categoriesDisplay = [""];
  String duration;
  TextEditingController titleController = TextEditingController();
  TextEditingController portionController = TextEditingController();
  FocusNode titleFocusNode = FocusNode();
  FocusNode portionFocusNode = FocusNode();
  List<IngredientsGroup> ingredientsGroup = [];
  List<Steps> steps = [];
  List<Map<String, Object>> ingredientsGroupSendToHttp = [];
  List<Map<String, Object>> ingredientsSendToHttp = [];
  List<Map<String, Object>> stepsSendToHttp = [];
  
  initState() {
    allCategories();
    Uuid uuid = Uuid();
    String ingredientUuidv4 = uuid.v4();
    String ingredientPerGroupUuidv4 = uuid.v4();
    String stepUuidv4 = uuid.v4();
    ingredientsGroup = [
      IngredientsGroup(
        uuid: ingredientPerGroupUuidv4,
        focusNode: FocusNode(),
        textEditingController: TextEditingController(text:""),
        ingredients: [
          Ingredients(
            uuid: ingredientUuidv4,
            focusNode: FocusNode(),
            textEditingController: TextEditingController()
          ),
        ]
      )
    ];
    steps = [ 
      Steps(
        uuid: stepUuidv4,
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
          ),
        ]
      )
    ];
  }

  void changeImageRecipe(PickedFile pickedFile) {
    if(pickedFile != null) {
      fileImageRecipe = File(pickedFile.path);
      filenameImageRecipe = pickedFile.path;
      notifyListeners();
    }
  }

  Future allCategories() async {
    String url = 'http://$baseurl:$port/api/v1/categories'; 
    try {
      http.Response response = await http.get(url);
      CategoryModel model = CategoryModel.fromJson(json.decode(response.body));
      List initialCategoriesDisplay = [];
      model.data.forEach((item) { 
        initialCategoriesDisplay.add(
          item.title
        );
      });
      categoriesDisplay = initialCategoriesDisplay;
      categoryName = categoriesDisplay.first;
      notifyListeners();
    } catch(error) {
      print(error);
    }
  }

  void incrementIngredientPerGroup(BuildContext context) {
    Uuid uuid = Uuid();
    String uuidv4IngredientPerGroup = uuid.v4();
    String uuidv4Ingredients = uuid.v4();
    if(ingredientsGroup.length >= 10) {
      SnackBar snackbar = SnackBar(
        backgroundColor: Colors.red[300],
        content: Text('Oops! Sudah Mencapai Batas Maksimal'),
        action: SnackBarAction(
          textColor: Colors.white,
          label: 'Tutup',
          onPressed: () {
            Scaffold.of(context).hideCurrentSnackBar();
          }
        ),
      );
      Scaffold.of(context).showSnackBar(snackbar);
    } else {
      ingredientsGroup.add(
        IngredientsGroup(
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
        )
      );
      FocusNode nextNode = ingredientsGroup[ingredientsGroup.length-1].focusNode;
      nextNode.requestFocus();
    }
    notifyListeners();
  }

  void decrementIngredientPerGroup(String uuid) {
    ingredientsGroup.removeWhere((item) => item.uuid == uuid);
    notifyListeners();
  }

  void incrementIngredients(BuildContext context, int i) {
    Uuid uuid = Uuid();
    String uuidv4 = uuid.v4();
    if(ingredientsGroup[i].ingredients.length >= 10) {
      SnackBar snackbar = SnackBar(
        backgroundColor: Colors.red[300],
        content: Text('Oops! Sudah Mencapai Batas Maksimal'),
        action: SnackBarAction(
          textColor: Colors.white,
          label: 'Tutup',
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
    ingredientsGroup[i].ingredients.removeWhere((item) => item.uuid == uuid);
    notifyListeners();
  }

  void incrementSteps(BuildContext context) {
    Uuid uuid = Uuid();
    if(steps.length >= 10) {
      SnackBar snackbar = SnackBar(
        backgroundColor: Colors.red[300],
        content: Text('Oops! Sudah Mencapai Batas Maksimal'),
        action: SnackBarAction(
          textColor: Colors.white,
          label: 'Tutup',
          onPressed: () {
            Scaffold.of(context).hideCurrentSnackBar();
          }
        ),
      );
      Scaffold.of(context).showSnackBar(snackbar);
    } else {
      steps.add(Steps(
        uuid: uuid.v4(),
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

  void stepsImage(int i, int z, PickedFile pickedFile) {  
    if(pickedFile != null) {
      steps[i].images[z].body = Image.file(File(pickedFile.path));
      steps[i].images[z].filename = pickedFile.path;
      notifyListeners();
    }
  }

  void decrementSteps(String uuid) {
    steps.removeWhere((item) => item.uuid == uuid);
    notifyListeners();
  }
  
  Future store(String title, String ingredientsGroupParam, String ingredients, String stepsParam, String portion) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, Object> extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    String userId = extractedUserData["userId"];
    String url = 'http://$baseurl:$port/api/v1/recipes/store'; 
    isLoading = true;
    notifyListeners();
    try {
      http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(url));
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
      if(fileImageRecipe != null) {
        http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
          'imageurl', filenameImageRecipe
        );
        request.files.add(multipartFile);
      }
      request.fields["duration"] = duration.toString();
      request.fields["title"] = title;
      request.fields["ingredientsGroup"] = ingredientsGroupParam;
      request.fields["ingredients"] = ingredients;
      request.fields["portion"] = portion; 
      request.fields["steps"] = stepsParam;
      request.fields["categoryName"] = categoryName;
      request.fields["userId"] = userId; 
      http.StreamedResponse response = await request.send().timeout(Duration(seconds: 60));
      if(response.statusCode == 200) {
        ingredientsGroupSendToHttp = [];
        ingredientsSendToHttp = [];
        stepsSendToHttp = [];
        isLoading = false;
        initState();
        notifyListeners();
      }
      String responseData = await response.stream.bytesToString();
      final responseDecoded = json.decode(responseData);   
      notifyListeners();
      return responseDecoded;
    } catch(error) {
      print(error);
    }
  }
  
}