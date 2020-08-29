import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quartet/quartet.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/RecipeShow.dart';
import '../profile/view.dart';
import '../../helpers/highlight.occurences.dart';
import '../../providers/recipe/show.dart';
import '../../constants/url.dart';
import './detail.dart';

class ShowRecipeScreen extends StatefulWidget {
  static const routeName = '/category-meals';

  @override
  _ShowRecipeScreenState createState() => _ShowRecipeScreenState();
}

class _ShowRecipeScreenState extends State<ShowRecipeScreen> {
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        Map<String, String> routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
        Provider.of<RecipeShow>(context, listen: false).getShow(routeArgs['uuid'], 5);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void selectRecipe(context, String title, String uuid, String userId) {
    Navigator.of(context).pushNamed(
      RecipeDetailScreen.routeName,
      arguments: {
        'uuid': uuid,
        'title': title,
        'userId': userId
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> routeArgs = ModalRoute.of(context).settings.arguments;
    String categoryTitle = routeArgs['title'];
    String recipeId = routeArgs['uuid'];
    return Scaffold(
      appBar: AppBar(
        title: Text(titleCase(categoryTitle)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: DataSearch());
            }
          )
        ],
      ),
      body: FutureBuilder(
        future: Provider.of<RecipeShow>(context, listen: false).getShow(recipeId),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if(snapshot.hasError) {
            return Consumer<RecipeShow>(
              builder: (context, recipeShowProvider, child) =>
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150.0,
                      child: Image.asset('assets/no-network.png')
                    ),
                    SizedBox(height: 15.0),
                    Text('Koneksi jaringan Anda buruk',
                      style: TextStyle(
                        fontSize: 16.0
                      ),
                    ),
                    SizedBox(height: 10.0),
                    GestureDetector(
                      child: Text('Coba Ulangi',
                        style: TextStyle(
                          fontSize: 16.0,
                          decoration: TextDecoration.underline
                        ),
                      ),
                      onTap: () {
                        setState((){});
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          return Consumer<RecipeShow>(
            child: Center(
              child: Text('Belum ada resep'),
            ),
            builder: (context, recipeProvider, child) => recipeProvider.getShowItem.length <= 0 ? child :
            RefreshIndicator(
              onRefresh: () => recipeProvider.refreshRecipe(recipeId),
              child: ListView.builder(
              controller: controller,
              itemCount: recipeProvider.getShowItem.length,
              itemBuilder: (context, i) {
                if(i == recipeProvider.getShowItem.length) 
                  return CircularProgressIndicator();
                  return InkWell(
                    onTap: () => selectRecipe(context, recipeProvider.getShowItem[i].title, recipeProvider.getShowItem[i].uuid, recipeProvider.getShowItem[i].userId),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)
                      ),
                      elevation: 4,
                      margin: EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15.0),
                                  topRight: Radius.circular(15.0),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: '$imagesRecipesUrl/${recipeProvider.getShowItem[i].imageurl}',
                                  imageBuilder: (context, imageProvider) => Container(
                                    width: double.infinity,
                                    height: 250.0,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  ),
                                  placeholder: (context, url) => Image.asset('assets/default-thumbnail.jpg'),
                                  errorWidget: (context, url, error) => Image.asset('assets/default-thumbnail.jpg'),
                                  fadeOutDuration: Duration(seconds: 1),
                                  fadeInDuration: Duration(seconds: 1),
                                ),
                              ),
                              Positioned(
                                bottom: 20.0,
                                right: 10.0,
                                child: Container(
                                  width: 300.0,
                                  color: Colors.black54,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 5.0,
                                    horizontal: 20.0,
                                  ),
                                  child: Text(
                                    titleCase(recipeProvider.getShowItem[i].title),
                                    style: TextStyle(
                                      fontSize: 26.0,
                                      color: Colors.white,
                                    ),
                                    softWrap: true,
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.all(20.0),
                            child: Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.schedule),
                                      SizedBox(width: 6.0),
                                      Text('${recipeProvider.getShowItem[i].duration.toString()} min'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.fastfood),
                                      SizedBox(width: 6.0),
                                      Text('${recipeProvider.getShowItem[i].portion}'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ViewProfileScreen()),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.only(top: 0.0, left: 0.0, right: 20.0, bottom: 15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.people),
                                  SizedBox(width: 6),
                                  RichText(
                                    text: TextSpan(
                                      text: 'Dibuat oleh : ',
                                      style: TextStyle(
                                        color: Colors.black, 
                                        fontSize: 16.0
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: '${recipeProvider.getShowItem[i].name}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0
                                          ),
                                        )
                                      ]
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              ),
            )
          );
        },
      )
    );
  }
}

class DataSearch extends SearchDelegate<String> {

  ThemeData appBarTheme(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.copyWith(
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.black),
      ),
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.black),
      textTheme: theme.textTheme.copyWith(
        headline6: TextStyle(
          color: Colors.black,
          fontSize: 20.0,
          fontWeight: FontWeight.w400
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        }
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation
      ),
      onPressed: () {
        close(context, null);
      }
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    RecipeShow recipeProvider = Provider.of<RecipeShow>(context);
    List<RecipeShowData> results = recipeProvider.getShowItem.where((item) => item.title.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, i) {
        return InkWell(
          onTap: () => {
            Navigator.of(context).pushNamed(
              RecipeDetailScreen.routeName,
              arguments: {
                "uuid": results[i].uuid,
                "title": results[i].title 
              }
            )
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0)
            ),
            elevation: 4.0,
            margin: EdgeInsets.all(10.0),
            child: Column(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0),
                      ),
                      child: CachedNetworkImage(
                        width: 50.0,
                        height: 50.0,
                        imageUrl: '${results[i].imageurl}',
                        placeholder: (context, url) => Image.asset('assets/default-thumbnail.jpg'),
                        errorWidget: (context, url, error) => Image.asset('assets/default-thumbnail.jpg'),
                        fadeOutDuration: Duration(seconds: 1),
                        fadeInDuration: Duration(seconds: 1),
                      ), 
                    ),
                    Positioned(
                      bottom: 20.0,
                      right: 10.0,
                      child: Container(
                        width: 300.0,
                        color: Colors.black54,
                        padding: EdgeInsets.symmetric(
                          vertical: 5.0,
                          horizontal: 20.0,
                        ),
                        child: Text(results[i].title,
                          style: TextStyle(
                            fontSize: 26.0,
                            color: Colors.white,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.schedule),
                          SizedBox(width: 6.0),
                          Text('${results[i].duration} min'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.fastfood),
                          SizedBox(width: 6.0),
                          Text('${results[i].portion}'),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 0.0, left: 0.0, right: 20.0, bottom: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.people),
                      SizedBox(width: 6),
                      RichText(
                        text: TextSpan(
                          text: 'Dibuat oleh : ',
                          style: TextStyle(
                            color: Colors.black, 
                            fontSize: 16.0
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: '${results[i].name}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0
                              ),
                            )
                          ]
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
  @override
  Widget buildSuggestions(BuildContext context) {
    RecipeShow recipeProvider = Provider.of<RecipeShow>(context);
    if(query.isEmpty) {
      return ListView.builder(
        itemCount: recipeProvider.searchSuggestionsItem.length,
        itemBuilder: (context, i) => Card(
          child: ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(
                RecipeDetailScreen.routeName,
                arguments: {
                  "uuid": recipeProvider.searchSuggestionsItem[i].uuid,
                  "title": recipeProvider.searchSuggestionsItem[i].title
                }
              );
              recipeProvider.popularViews(recipeProvider.searchSuggestionsItem[i].uuid);
            },
            leading: CachedNetworkImage(
              width: 50.0,
              height: 50.0,
              imageUrl: '${recipeProvider.searchSuggestionsItem[i].imageurl}',
              placeholder: (context, url) => Image.asset('assets/default-thumbnail.jpg'),
              errorWidget: (context, url, error) => Image.asset('assets/default-thumbnail.jpg'),
              fadeOutDuration: Duration(seconds: 1),
              fadeInDuration: Duration(seconds: 1),
            ),
            title: RichText(
              text: TextSpan(
                children: highlightOccurrences(recipeProvider.searchSuggestionsItem[i].title, query),
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold
                ),
              )
            )
          ),
        ),
      );
    }
    List<RecipeShowData> suggestionsList = recipeProvider.getShowItem.where((item) => item.title.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: suggestionsList.length,
      itemBuilder: (context, index) => Card(
        child: ListTile(
          onTap: () {
            Navigator.of(context).pushNamed(
              RecipeDetailScreen.routeName,
              arguments: {
                'uuid': suggestionsList[index].uuid,
                'title': suggestionsList[index].title
              }
            );
            recipeProvider.popularViews(suggestionsList[index].uuid);
          },
          leading: CachedNetworkImage(
            width: 50.0,
            height: 50.0,
            imageUrl: '${suggestionsList[index].imageurl}',
            placeholder: (context, url) => Image.asset('assets/default-thumbnail.jpg'),
            errorWidget: (context, url, error) => Image.asset('assets/default-thumbnail.jpg'),
            fadeOutDuration: Duration(seconds: 1),
            fadeInDuration: Duration(seconds: 1),
          ),
          title: RichText(
            text: TextSpan(
              children: highlightOccurrences(suggestionsList[index].title, query),
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold
              ),
            )
          )
        ),
      ),
    );
  }
}
