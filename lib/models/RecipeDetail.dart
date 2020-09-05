class RecipeDetailModel {
  int status;
  bool error;
  String message;
  RecipeDetailModelData data;

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
    data: json["data"] == null ? null : RecipeDetailModelData.fromJson(json["data"]),
  );
}

class RecipeDetailModelData {
  List<RecipeDetailData> recipes;
  List<IngredientsGroupDetail> ingredientsGroup;
  List<StepDetailData> steps;

  RecipeDetailModelData({
    this.recipes,
    this.ingredientsGroup,
    this.steps,
  });

  factory RecipeDetailModelData.fromJson(Map<String, dynamic> json) => RecipeDetailModelData(
    recipes: json["recipes"] == null ? null : List<RecipeDetailData>.from(json["recipes"].map((x) => RecipeDetailData.fromJson(x))),
    ingredientsGroup: json["ingredientsGroup"] == null ? null : List<IngredientsGroupDetail>.from(json["ingredientsGroup"].map((x) => IngredientsGroupDetail.fromJson(x))),
    steps: json["steps"] == null ? null : List<StepDetailData>.from(json["steps"].map((x) => StepDetailData.fromJson(x))),
  );
}

class RecipeDetailData {
  String uuid;
  String title;
  String imageurl;
  String portion;
  String duration;
  int isfavorite;
  RecipeDetailDataUser user;
  RecipeDetailDataCategory category;
  RecipeDetailDataCountry country;

  RecipeDetailData({
    this.uuid,
    this.title,
    this.imageurl,
    this.portion, 
    this.duration,
    this.isfavorite,
    this.user,
    this.category, 
    this.country
  });

  factory RecipeDetailData.fromJson(Map<String, dynamic> json) => RecipeDetailData(
    uuid: json["uuid"] == null ? null : json["uuid"],
    title: json["title"] == null ? null : json["title"],
    imageurl: json["imageurl"] == null ? null : json["imageurl"],
    portion: json["portion"] == null ? null : json["portion"],
    duration: json["duration"] == null ? null : json["duration"],
    isfavorite: json["isfavorite"] == null ? null : json["isfavorite"],
    user: RecipeDetailDataUser.fromJson(json["user"]),
    category: RecipeDetailDataCategory.fromJson(json["category"]),
    country: RecipeDetailDataCountry.fromJson(json["country"])
  );
}

class IngredientsGroupDetail {
  String uuid;
  String body;
  List<Ingredients> ingredients;

  IngredientsGroupDetail({
    this.uuid,
    this.body,
    this.ingredients
  });

  factory IngredientsGroupDetail.fromJson(Map<String, dynamic> json) => IngredientsGroupDetail(
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
  dynamic body;

  StepsDetailImages({
    this.uuid,
    this.body
  });

  factory StepsDetailImages.fromJson(Map<String, dynamic> json) => StepsDetailImages(
    uuid: json["uuid"] == null ? null : json["uuid"],
    body: json["body"] == null ? null : json["body"],
  );
}

class RecipeDetailDataCategory {
  RecipeDetailDataCategory({
    this.title,
  });

  String title;

  factory RecipeDetailDataCategory.fromJson(Map<String, dynamic> json) => RecipeDetailDataCategory(
    title: json["title"],
  );
}

class RecipeDetailDataCountry {
  RecipeDetailDataCountry({
    this.name,
  });

  String name;

  factory RecipeDetailDataCountry.fromJson(Map<String, dynamic> json) => RecipeDetailDataCountry(
    name: json["name"],
  );
}


class RecipeDetailDataUser {
  String uuid;
  String name;

  RecipeDetailDataUser({
    this.uuid,
    this.name,
  });

  factory RecipeDetailDataUser.fromJson(Map<String, dynamic> json) => RecipeDetailDataUser(
    uuid: json["uuid"],
    name: json["name"],
  );
}