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

class Ingredients {
  String id;
  String body;

  Ingredients({
    this.id,
    this.body,
  });

  factory Ingredients.fromJson(Map<String, dynamic> json) => Ingredients(
    id: json["id"] == null ? null : json["id"],
    body: json["body"] == null ? null : json["body"],
  );
}

class Steps {
  String id;
  String body;

  Steps({
    this.id,
    this.body,
  });

  factory Steps.fromJson(Map<String, dynamic> json) => Steps(
    id: json["id"] == null ? null : json["id"],
    body: json["body"] == null ? null : json["body"],
  );
}

class Recipes {
  String id;
  String title;
  String imageUrl;
  String categoryId;

  Recipes({
    this.id,
    this.title,
    this.imageUrl,
    this.categoryId,
  });

  factory Recipes.fromJson(Map<String, dynamic> json) => Recipes(
    id: json["id"] == null ? null : json["id"],
    title: json["title"] == null ? null : json["title"],
    imageUrl: json["imageUrl"] == null ? null : json["imageUrl"],
    categoryId: json["category_id"] == null ? null : json["category_id"],
  );
}
