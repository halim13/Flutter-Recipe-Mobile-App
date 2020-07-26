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
  String imageUrl;

  SearchSuggestionsData({
    this.uuid,
    this.title,
    this.imageUrl,
  });

  factory SearchSuggestionsData.fromJson(Map<String, dynamic> json) => SearchSuggestionsData(
    uuid: json["uuid"],
    title: json["title"],
    imageUrl: json["imageUrl"],
  );
}
