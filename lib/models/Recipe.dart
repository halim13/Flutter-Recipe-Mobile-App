import 'package:flutter/cupertino.dart';

class RecipeModel {
  int status;
  bool error;
  String message;
  Data data;

  RecipeModel({
    this.status,
    this.error,
    this.message,
    this.data,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) => RecipeModel(
    status: json["status"] == null ? null : json["status"],
    error: json["error"] == null ? null : json["error"],
    message: json["message"] == null ? null : json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );
}

class Data {
  List<Recipes> recipes;
  List<IngredientsGroup> ingredientsGroup;
  List<Steps> steps;

  Data({
    this.recipes,
    this.ingredientsGroup,
    this.steps,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    recipes: json["recipes"] == null ? null : List<Recipes>.from(json["recipes"].map((x) => Recipes.fromJson(x))),
    ingredientsGroup: json["ingredientsGroup"] == null ? null : List<IngredientsGroup>.from(json["ingredientsGroup"].map((x) => IngredientsGroup.fromJson(x))),
    steps: json["steps"] == null ? null : List<Steps>.from(json["steps"].map((x) => Steps.fromJson(x))),
  );
}

class Recipes {
  int id;
  String uuid;
  String title;
  String duration;
  String imageUrl;
  String portion;
  int isPublished;
  String categoryName;
  String foodCountryName;
  List<CategoryList> categoryList;
  List<FoodCountryList> foodCountriesList;

  Recipes({
    this.id,
    this.uuid,
    this.title,
    this.duration,
    this.imageUrl,
    this.portion,
    this.isPublished,
    this.categoryName,
    this.foodCountryName,
    this.categoryList,
    this.foodCountriesList
  });

  factory Recipes.fromJson(Map<String, dynamic> json) => Recipes(
    id: json["id"] == null ? null : json["id"],
    uuid: json["uuid"] == null ? null : json["uuid"],
    title: json["title"] == null ? null : json["title"],
    duration: json["duration"] == null ? null : json["duration"],
    imageUrl: json["imageUrl"] == null ? null : json["imageUrl"],
    portion: json["portion"] == null ? null : json["portion"],
    isPublished: json["ispublished"] == null ? null : json["ispublished"],
    categoryName: json["category_name"] == null ? null : json["category_name"],
    foodCountryName: json["food_country_name"] == null ? null : json["food_country_name"],
    categoryList: List<CategoryList>.from(json["category_list"].map((x) => CategoryList.fromJson(x))),
    foodCountriesList: List<FoodCountryList>.from(json["food_country_list"].map((x) => FoodCountryList.fromJson(x))),
  );
}

class CategoryList {
  int id;
  String uuid;
  String title;
  String color;
  String cover;
  
  CategoryList({
    this.id,
    this.uuid,
    this.title,
    this.color,
    this.cover
  });
  
  factory CategoryList.fromJson(Map<String, dynamic> json) => CategoryList(
    id: json["id"] == null ? null : json["id"],
    uuid: json["uuid"] == null ? null : json["uuid"],
    title: json["title"] == null ? null : json["title"],
    color: json["color"] == null ? null : json["color"],
    cover: json["cover"] == null ? null : json["cover"]
  );
}

class FoodCountryList {
  int id;
  String uuid;
  String name;
  
  FoodCountryList({
    this.id,
    this.uuid,
    this.name,
  });
  
  factory FoodCountryList.fromJson(Map<String, dynamic> json) => FoodCountryList(
    id: json["id"] == null ? null : json["id"],
    uuid: json["uuid"] == null ? null : json["uuid"],
    name: json["name"] == null ? null : json["name"],
  );
}

class IngredientsGroup {
  int id;
  String uuid;
  dynamic body;
  List<Ingredients> ingredients;
  FocusNode focusNode;
  TextEditingController textEditingController;

  IngredientsGroup({
    this.id,
    this.uuid,
    this.body,
    this.ingredients,
    this.focusNode,
    this.textEditingController
  });

  factory IngredientsGroup.fromJson(Map<String, dynamic> json) => IngredientsGroup(
    id: json["id"] == null ? null : json["id"],
    uuid: json["uuid"] == null ? null : json["uuid"],
    body: json["body"] == null ? null : json["body"],
    ingredients: List<Ingredients>.from(json["ingredients"].map((x) => Ingredients.fromJson(x))),
  );
 }

class Ingredients {
  int id;
  String uuid;
  String body;
  FocusNode focusNode;
  TextEditingController textEditingController;

  Ingredients({
    this.id,
    this.uuid,
    this.body,
    this.focusNode,
    this.textEditingController
  });

  factory Ingredients.fromJson(Map<String, dynamic> json) => Ingredients(
    id: json["id"] == null ? null : json["id"],
    uuid: json["uuid"] == null ? null : json["uuid"],
    body: json["body"] == null ? null : json["body"],
    focusNode: FocusNode(),
    textEditingController: json["body"] == null ? TextEditingController(text: "")  : TextEditingController(text: json["body"])
  );
}

class Steps {
  int id;
  String uuid;
  String body;
  List<StepsImages> images;
  FocusNode focusNode;
  TextEditingController textEditingController;

  Steps({
    this.id,
    this.uuid,
    this.body,
    this.images,
    this.focusNode,
    this.textEditingController
  });

  factory Steps.fromJson(Map<String, dynamic> json) => Steps(
    id: json["id"] == null ? null : json["id"],
    uuid: json["uuid"] == null ? null : json["uuid"],
    body: json["body"] == null ? null : json["body"],
    images: json["stepsImages"] == null ? null : List<StepsImages>.from(json["stepsImages"].map((x) => StepsImages.fromJson(x)))
  );
}

class StepsImages {
  int id;
  String uuid;
  dynamic body;
  String filename;

  StepsImages({
    this.id,
    this.uuid,
    this.body,
    this.filename
  });

  factory StepsImages.fromJson(Map<String, dynamic> json) => StepsImages(
    id: json["id"] == null ? null : json["id"],
    uuid: json["uuid"] == null ? null : json["uuid"],
    body: json["body"] == null ? null : json["body"],
    filename: json["filename"] == null ? null : json["filename"]
  );
}
