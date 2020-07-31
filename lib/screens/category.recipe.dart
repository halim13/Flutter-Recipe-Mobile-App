import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    String mealId = routeArgs['uuid'];
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryTitle),
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
        future: Provider.of<RecipeShow>(context, listen: false).show(mealId),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if(snapshot.hasError) {
            return Center(
              child: Text('Oops! Something went wrong! Please Try Again.')
            );
          }
          return Consumer<RecipeShow>(
            child: Center(
              child: const Text('You have no meals yet, start adding some!'),
            ),
            builder: (context, value, ch) => value.showRecipeItem.length <= 0 ? ch :
            RefreshIndicator(
              onRefresh: () => value.refreshRecipe(mealId),
              child: ListView.builder(
              controller: controller,
              itemCount: value.showRecipeItem.length,
              itemBuilder: (context, index) {
                if(index == value.showRecipeItem.length) 
                  return CircularProgressIndicator();
                  return InkWell(
                    onTap: () => selectMeal(context, value.showRecipeItem[index].title.toString(), value.showRecipeItem[index].uuid),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)
                      ),
                      elevation: 4,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                                child: Image.network('$imagesRecipesUrl/${value.showRecipeItem[index].imageurl}',
                                  height: 250,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 20,
                                right: 10,
                                child: Container(
                                  width: 300,
                                  color: Colors.black54,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: 20,
                                  ),
                                  child: Text(value.showRecipeItem[index].title.toString(),
                                    style: TextStyle(
                                      fontSize: 26,
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
                            padding: EdgeInsets.all(20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.schedule),
                                    SizedBox(width: 6),
                                    Text('${value.showRecipeItem[index].duration.toString()} min'),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.work),
                                    SizedBox(width: 6),
                                    Text(value.showRecipeItem[index].complexities.toString()),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.attach_money),
                                    SizedBox(width: 6),
                                    Text(value.showRecipeItem[index].affordabilities.toString()),
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
          fontSize: 20,
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
    final provider = Provider.of<RecipeShow>(context);
    final results = provider.showRecipeItem.where((item) => item.title.toLowerCase().contains(query.toLowerCase())).toList();

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
              borderRadius: BorderRadius.circular(15)
            ),
            elevation: 4,
            margin: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: Image.network(results[index].imageurl,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 10,
                      child: Container(
                        width: 300,
                        color: Colors.black54,
                        padding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 20,
                        ),
                        child: Text(results[index].title,
                          style: TextStyle(
                            fontSize: 26,
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
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(Icons.schedule),
                          SizedBox(width: 6),
                          Text('${results[index].duration} min'),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Icon(Icons.work),
                          SizedBox(width: 6),
                          Text(results[index].complexities),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Icon(Icons.attach_money),
                          SizedBox(width: 6),
                          Text(results[index].affordabilities),
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
    final provider = Provider.of<RecipeShow>(context);
    if(query.isEmpty) {
      return ListView.builder(
        itemCount: provider.searchSuggestionsItem.length,
        itemBuilder: (context, index) => Card(
          child: ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(
                RecipeDetailScreen.routeName,
                arguments: provider.searchSuggestionsItem[index].uuid
              );
              provider.popularViews(provider.searchSuggestionsItem[index].uuid);
            },
            leading: Image.network(
              provider.searchSuggestionsItem[index].imageUrl,
              height: 50,
              width: 50,
              alignment: Alignment.center,
              fit: BoxFit.cover,
            ),
            title: RichText(
              text: TextSpan(
                children: highlightOccurrences(provider.searchSuggestionsItem[index].title, query),
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
    final suggestionsList = provider.showRecipe.where((item) => item.title.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: suggestionsList.length,
      itemBuilder: (context, index) => Card(
        child: ListTile(
          onTap: () {
            Navigator.of(context).pushNamed(
              RecipeDetailScreen.routeName,
              arguments: suggestionsList[index].uuid
            );
            provider.popularViews(suggestionsList[index].uuid);
          },
          leading: Image.network(
            suggestionsList[index].imageurl,
            height: 50,
            width: 50,
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
