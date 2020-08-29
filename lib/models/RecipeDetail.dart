class RecipeDetailModel {
  int status;
  bool error;
  String message;
  RecipeDetailDatas data;

  RecipeDetailModel({
    this.status,
    this.error,
    this.message,
    this.data,
  });

  factory RecipeDetailModel.fromJson(Map<String, dynamic> json) => RecipeDetailModel(
    status: json["status"] == null ? null : json["status"],
    error: json["error"] == null ? null : json["error"],
    message: json["message"] == null ? null : json["message"],
    data: json["data"] == null ? null : RecipeDetailDatas.fromJson(json["data"]),
  );
}

class RecipeDetailDatas {
  List<RecipeDetailData> recipes;
  List<IngredientsGroup> ingredientsGroup;
  List<StepDetailData> steps;

  RecipeDetailDatas({
    this.recipes,
    this.ingredientsGroup,
    this.steps,
  });

  factory RecipeDetailDatas.fromJson(Map<String, dynamic> json) => RecipeDetailDatas(
    recipes: json["recipes"] == null ? null : List<RecipeDetailData>.from(json["recipes"].map((x) => RecipeDetailData.fromJson(x))),
    ingredientsGroup: json["ingredientsGroup"] == null ? null : List<IngredientsGroup>.from(json["ingredientsGroup"].map((x) => IngredientsGroup.fromJson(x))),
    steps: json["steps"] == null ? null : List<StepDetailData>.from(json["steps"].map((x) => StepDetailData.fromJson(x))),
  );
}

class RecipeDetailData {
  int id;
  String uuid;
  String title;
  String imageUrl;
  int isfavorite;

  RecipeDetailData({
    this.id,
    this.uuid,
    this.title,
    this.imageUrl,
    this.isfavorite
  });

  factory RecipeDetailData.fromJson(Map<String, dynamic> json) => RecipeDetailData(
    id: json["id"] == null ? null : json["id"],
    uuid: json["uuid"] == null ? null : json["uuid"],
    title: json["title"] == null ? null : json["title"],
    imageUrl: json["imageUrl"] == null ? null : json["imageUrl"],
    isfavorite: json["isfavorite"] == null ? null : json["isfavorite"]
  );
}

class IngredientsGroup {
  String uuid;
  String body;
  List<Ingredients> ingredients;

  IngredientsGroup({
    this.uuid,
    this.body,
    this.ingredients
  });

  factory IngredientsGroup.fromJson(Map<String, dynamic> json) => IngredientsGroup(
    uuid: json["uuid"] == null ? null : json["uuid"],
    body: json["body"] == null ? null : json["body"],
    ingredients: List<Ingredients>.from(json["ingredients"].map((x) => Ingredients.fromJson(x))),
  );
}

class Ingredients {
  String uuid;
  String body;

  Ingredients({
    this.uuid,
    this.body,
  });

  factory Ingredients.fromJson(Map<String, dynamic> json) => Ingredients(
    uuid: json["uuid"] == null ? null : json["uuid"],
    body: json["body"] == null ? null : json["body"],
  );
}

class StepDetailData {
  String uuid;
  String body;
  List<StepsDetailImages> stepsImages;
  StepDetailData({
    this.uuid,
    this.body,
    this.stepsImages
  });

  factory StepDetailData.fromJson(Map<String, dynamic> json) => StepDetailData(
    uuid: json["uuid"] == null ? null : json["uuid"],
    body: json["body"] == null ? null : json["body"],
    stepsImages: json["stepsImages"] == null ? null : List<StepsDetailImages>.from(json["stepsImages"].map((x) => StepsDetailImages.fromJson(x)))
  );
}

class StepsDetailImages {
  String uuid;
  String body;

  StepsDetailImages({
    this.uuid,
    this.body
  });

  factory StepsDetailImages.fromJson(Map<String, dynamic> json) => StepsDetailImages(
    uuid: json["uuid"] == null ? null : json["uuid"],
    body: json["body"] == null ? null : json["body"],
  );
}