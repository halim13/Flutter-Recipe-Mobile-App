import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quartet/quartet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/RecipeShow.dart';
import '../helpers/highlight.occurences.dart';
import '../providers/recipe.show.dart';
import '../constants/url.dart';
import './recipe.detail.dart';

class CategoryMealsScreen extends StatefulWidget {
  static const routeName = '/category-meals';

  @override
  _CategoryMealsScreenState createState() => _CategoryMealsScreenState();
}

class _CategoryMealsScreenState extends State<CategoryMealsScreen> {
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
        Provider.of<RecipeShow>(context, listen: false).show(routeArgs['uuid'], 5);
      }
    });
  }
  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void selectMeal(context, String title, String uuid) {
    Navigator.of(context).pushNamed(
      RecipeDetailScreen.routeName,
      arguments: {
        'uuid': uuid,
        'title': title,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
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
        future: Provider.of<RecipeShow>(context, listen: false).show(recipeId),
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
                    Text('Koneksi jaringan Anda buruk.',
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
              child: Text('Belum ada resep.'),
            ),
            builder: (context, recipeProvider, child) => recipeProvider.showRecipeItem.length <= 0 ? child :
            RefreshIndicator(
              onRefresh: () => recipeProvider.refreshRecipe(recipeId),
              child: ListView.builder(
              controller: controller,
              itemCount: recipeProvider.showRecipeItem.length,
              itemBuilder: (context, index) {
                if(index == recipeProvider.showRecipeItem.length) 
                  return CircularProgressIndicator();
                  return InkWell(
                    onTap: () => selectMeal(context, recipeProvider.showRecipeItem[index].title.toString(), recipeProvider.showRecipeItem[index].uuid),
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
                                  imageUrl: '$imagesRecipesUrl/${recipeProvider.showRecipeItem[index].imageurl}',
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
                                  fadeInDuration: Duration(seconds: 3),
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
                                    titleCase(recipeProvider.showRecipeItem[index].title),
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
                          Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.schedule),
                                    SizedBox(width: 6),
                                    Text('${recipeProvider.showRecipeItem[index].duration.toString()} min'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.fastfood),
                                    SizedBox(width: 6),
                                    Text('${recipeProvider.showRecipeItem[index].portion}'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.people),
                                    SizedBox(width: 6),
                                    Text('Dibuat oleh ${recipeProvider.showRecipeItem[index].name}'),
                                  ],
                                ),
                              ],
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
    final ThemeData theme = Theme.of(context);
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
    RecipeShow provider = Provider.of<RecipeShow>(context);
    List<RecipeShowData> results = provider.showRecipeItem.where((item) => item.title.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => {
            Navigator.of(context).pushNamed(
              RecipeDetailScreen.routeName,
              arguments: results[index].id
            )
          },
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
                      child: Image.network(results[index].imageurl,
                        height: 250.0,
                        width: double.infinity,
                        fit: BoxFit.cover,
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
                        child: Text(results[index].title,
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
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.schedule),
                          SizedBox(width: 6.0),
                          Text('${results[index].duration} min'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.people),
                          SizedBox(width: 6),
                          Text('Dibuat oleh ${results[index].name}'),
                        ],
                      ),
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
    final recipeProvider = Provider.of<RecipeShow>(context);
    if(query.isEmpty) {
      return ListView.builder(
        itemCount: recipeProvider.searchSuggestionsItem.length,
        itemBuilder: (context, i) => Card(
          child: ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(
                RecipeDetailScreen.routeName,
                arguments: recipeProvider.searchSuggestionsItem[i].uuid
              );
              recipeProvider.popularViews(recipeProvider.searchSuggestionsItem[i].uuid);
            },
            leading: Image.network(
              recipeProvider.searchSuggestionsItem[i].imageUrl,
              height: 50.0,
              width: 50.0,
              alignment: Alignment.center,
              fit: BoxFit.cover,
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
    final suggestionsList = recipeProvider.showRecipe.where((item) => item.title.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: suggestionsList.length,
      itemBuilder: (context, index) => Card(
        child: ListTile(
          onTap: () {
            Navigator.of(context).pushNamed(
              RecipeDetailScreen.routeName,
              arguments: suggestionsList[index].uuid
            );
            recipeProvider.popularViews(suggestionsList[index].uuid);
          },
          leading: Image.network(
            suggestionsList[index].imageurl,
            height: 50.0,
            width: 50.0,
            alignment: Alignment.center,
            fit: BoxFit.cover,
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
