class SearchSuggestionModel {
  int status;
  bool error;
  String message;
  List<SearchSuggestionsData> data;

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
    data: List<SearchSuggestionsData>.from(json["data"].map((x) => SearchSuggestionsData.fromJson(x))),
  );
}

class SearchSuggestionsData {
  String uuid;
  String title;
  String duration;
  String imageurl;
  String portion;
  String userId;
  String name;

  SearchSuggestionsData({
    this.uuid,
    this.title,
    this.duration,
    this.imageurl,
    this.portion,
    this.userId,
    this.name
  });

  factory SearchSuggestionsData.fromJson(Map<String, dynamic> json) => SearchSuggestionsData(
    uuid: json["uuid"] == null ? null : json["uuid"],
    title: json["title"] == null ? null : json["title"],
    duration: json["duration"] == null ? null : json["duration"],
    imageurl: json["imageurl"] == null ? null : json["imageurl"],
    portion: json["portion"] == null ? null : json["portion"],
    userId: json["user_id"] == null ? null : json["user_id"],
    name: json["name"] == null ? null : json["name"]
  );
}
