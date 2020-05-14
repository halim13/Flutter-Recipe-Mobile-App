import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/highlight_occurences.dart';
import '../providers/meals_show.dart';
import '../screens/meal_detail_screen.dart';

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
        Provider.of<MealsShow>(context, listen: false).show(routeArgs['id'], 5);
      }
    });
  }
  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void selectMeal(context, String id) {
    Navigator.of(context).pushNamed(
      MealDetailScreen.routeName,
      arguments: id
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
    String categoryTitle = routeArgs['title'];
    String mealId = routeArgs['id'];
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
        future: Provider.of<MealsShow>(context, listen: false).show(mealId),
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
          return Consumer<MealsShow>(
            child: Center(
              child: const Text('You have no meals yet, start adding some!'),
            ),
            builder: (context, value, ch) => value.showMealItem.length <= 0 ? ch :
            RefreshIndicator(
              onRefresh: () => value.refreshMeals(mealId),
              child: ListView.builder(
              controller: controller,
              itemCount: value.showMealItem.length,
              itemBuilder: (context, index) {
                if(index == value.showMealItem.length) 
                  return CircularProgressIndicator();
                  return InkWell(
                    onTap: () => selectMeal(context, value.showMealItem[index].id),
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
                                child: Image.network(value.showMealItem[index].imageurl,
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
                                  child: Text(value.showMealItem[index].title,
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
                                    Text('${value.showMealItem[index].duration} min'),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.work),
                                    SizedBox(width: 6),
                                    Text(value.showMealItem[index].complexities),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.attach_money),
                                    SizedBox(width: 6),
                                    Text(value.showMealItem[index].affordabilities),
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
    final provider = Provider.of<MealsShow>(context);
    final results = provider.showMealItem.where((item) => item.title.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => {
            Navigator.of(context).pushNamed(
              MealDetailScreen.routeName,
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
    final provider = Provider.of<MealsShow>(context);
    if(query.isEmpty) {
      return ListView.builder(
        itemCount: provider.searchSuggestionsItem.length,
        itemBuilder: (context, index) => Card(
          child: ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(
                MealDetailScreen.routeName,
                arguments: provider.searchSuggestionsItem[index].id
              );
              provider.popularViews(provider.searchSuggestionsItem[index].id);
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
    final suggestionsList = provider.showMeal.where((item) => item.title.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: suggestionsList.length,
      itemBuilder: (context, index) => Card(
        child: ListTile(
          onTap: () {
            Navigator.of(context).pushNamed(
              MealDetailScreen.routeName,
              arguments: suggestionsList[index].id
            );
            provider.popularViews(suggestionsList[index].id.toString());
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
