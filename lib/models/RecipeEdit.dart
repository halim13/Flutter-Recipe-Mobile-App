class RecipeEditModel {
  int status;
  bool error;
  String message;
  Data data;

  RecipeEditModel({
    this.status,
    this.error,
    this.message,
    this.data,
  });

  factory RecipeEditModel.fromJson(Map<String, dynamic> json) => RecipeEditModel(
    status: json["status"] == null ? null : json["status"],
    error: json["error"] == null ? null : json["error"],
    message: json["message"] == null ? null : json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );
}

class Data {
  List<Recipes> recipes;
  List<Ingredients> ingredients;
  List<Steps> steps;

  Data({
    this.recipes,
    this.ingredients,
    this.steps,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    recipes: json["recipes"] == null ? null : List<Recipes>.from(json["recipes"].map((x) => Recipes.fromJson(x))),
    ingredients: json["ingredients"] == null ? null : List<Ingredients>.from(json["ingredients"].map((x) => Ingredients.fromJson(x))),
    steps: json["steps"] == null ? null : List<Steps>.from(json["steps"].map((x) => Steps.fromJson(x))),
  );
}

class Recipes {
  int id;
  String uuid;
  String title;
  String imageUrl;
  String categoryName;
  List<CategoryList> categoryList;

  Recipes({
    this.id,
    this.uuid,
    this.title,
    this.imageUrl,
    this.categoryName,
    this.categoryList,
  });

  factory Recipes.fromJson(Map<String, dynamic> json) => Recipes(
    id: json["id"] == null ? null : json["id"],
    uuid: json["uuid"] == null ? null : json["uuid"],
    title: json["title"] == null ? null : json["title"],
    imageUrl: json["imageUrl"] == null ? null : json["imageUrl"],
    categoryName: json["category_name"] == null ? null : json["category_name"],
    categoryList: List<CategoryList>.from(json["category_list"].map((x) => CategoryList.fromJson(x))),
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

class Ingredients {
  int id;
  String uuid;
  String body;

  Ingredients({
    this.id,
    this.uuid,
    this.body,
  });

  factory Ingredients.fromJson(Map<String, dynamic> json) => Ingredients(
    id: json["id"] == null ? null : json["id"],
    uuid: json["uuid"] == null ? null : json["uuid"],
    body: json["body"] == null ? null : json["body"],
  );
}

class Steps {
  int id;
  String uuid;
  String body;
  List<StepsImages> images;

  Steps({
    this.id,
    this.uuid,
    this.body,
    this.images
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
