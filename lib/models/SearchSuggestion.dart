class SearchSuggestionModel {
  int status;
  bool error;
  String message;
  List<SearchSuggestionModelData> data;

  SearchSuggestionModel({
    this.status,
    this.error,
    this.message,
    this.data,
  });

  factory SearchSuggestionModel.fromJson(Map<String, dynamic> json) => SearchSuggestionModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: List<SearchSuggestionModelData>.from(json["data"].map((x) => SearchSuggestionModelData.fromJson(x))),
  );
}

class SearchSuggestionModelData {
  String uuid;
  String title;
  String duration;
  String imageurl;
  String portion;
  SearchSuggestionModelDataUser user;
  SearchSuggestionModelDataCategory category;
  SearchSuggestionModelDataCountry country;


  SearchSuggestionModelData({
    this.uuid,
    this.title,
    this.duration,
    this.imageurl,
    this.portion,
    this.user, 
    this.category,
    this.country
  });

  factory SearchSuggestionModelData.fromJson(Map<String, dynamic> json) => SearchSuggestionModelData(
    uuid: json["uuid"] == null ? null : json["uuid"],
    title: json["title"] == null ? null : json["title"],
    duration: json["duration"] == null ? null : json["duration"],
    imageurl: json["imageurl"] == null ? null : json["imageurl"],
    portion: json["portion"] == null ? null : json["portion"],
    user: SearchSuggestionModelDataUser.fromJson(json["user"]),
    category: SearchSuggestionModelDataCategory.fromJson(json["category"]),
    country: SearchSuggestionModelDataCountry.fromJson(json["country"]),
  );
}

class SearchSuggestionModelDataCategory {
  SearchSuggestionModelDataCategory({
    this.title,
  });

  String title;

  factory SearchSuggestionModelDataCategory.fromJson(Map<String, dynamic> json) => SearchSuggestionModelDataCategory(
    title: json["title"],
  );
}

class SearchSuggestionModelDataCountry {
  SearchSuggestionModelDataCountry({
    this.name,
  });

  String name;

  factory SearchSuggestionModelDataCountry.fromJson(Map<String, dynamic> json) => SearchSuggestionModelDataCountry(
    name: json["name"],
  );
}

class SearchSuggestionModelDataUser {
  SearchSuggestionModelDataUser({
    this.uuid,
    this.name,
  });

  String uuid;
  String name;

  factory SearchSuggestionModelDataUser.fromJson(Map<String, dynamic> json) => SearchSuggestionModelDataUser(
    uuid: json["uuid"],
    name: json["name"],
  );
}
