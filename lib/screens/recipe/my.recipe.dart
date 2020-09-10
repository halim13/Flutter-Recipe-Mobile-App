import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quartet/quartet.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../helpers/highlight.occurences.dart';
import '../../constants/url.dart';
import '../../models/RecipeShow.dart';
import '../../providers/recipe/my.recipe.dart';
import '../../screens/profile/view.dart';
import '../../helpers/connectivity.service.dart';
import '../../helpers/show.error.dart';

class MyRecipeScreen extends StatefulWidget {
  @override
  _MyRecipeScreenState createState() => _MyRecipeScreenState();
}

class _MyRecipeScreenState extends State<MyRecipeScreen> {
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        Provider.of<MyRecipe>(context, listen: false).getShow(5);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void detailRecipe(
    BuildContext context, 
    String uuid, 
    String title, 
    String userId,
  ) {
    Navigator.of(context).pushNamed(
      '/detail-recipe',
      arguments: {
        'uuid': uuid,
        'title': title,
        'userId': userId
      },
    );
  }

  refresh() {
    setState((){});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Recipes'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context, 
                delegate: DataSearch()
              );
            }
          )
        ],
      ),
      body: FutureBuilder(
        future: Provider.of<MyRecipe>(context, listen: false).getShow(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if(snapshot.hasError) {
            return ShowError(
              notifyParent: refresh,
            );
          }
          return Consumer<MyRecipe>(
            child: Center(
              child: Text('There is no Recipes yet',
                style: TextStyle(
                  fontSize: 16.0
                ),
              ),
            ),
            builder: (BuildContext context, MyRecipe recipeProvider, Widget child) => recipeProvider.getShowItem.length <= 0 ? child :
            RefreshIndicator(
              onRefresh: () => recipeProvider.refreshRecipe(),
              child: ListView.builder(
                controller: controller,
                itemCount: recipeProvider.getShowItem.length,
                itemBuilder: (BuildContext context, int i) {
                  return ConnectivityService(
                    widget: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)
                      ),
                      elevation: 4.0,
                      margin: EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              InkWell(
                                onTap: () {
                                  detailRecipe(
                                    context, 
                                    recipeProvider.getShowItem[i].uuid,
                                    recipeProvider.getShowItem[i].title, 
                                    recipeProvider.getShowItem[i].user.uuid,
                                  );
                                },
                                child: ClipRRect(
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.schedule),
                                    SizedBox(width: 6.0),
                                    Text('${recipeProvider.getShowItem[i].duration} min'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.fastfood),
                                    SizedBox(width: 6.0),
                                    Text('${recipeProvider.getShowItem[i].portion} Portion'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ViewProfileScreen(recipeProvider.getShowItem[i].user.uuid, recipeProvider.getShowItem[i].user.name)),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.only(top: 0.0, left: 20.0, right: 20.0, bottom: 15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.flag),
                                          SizedBox(width: 6.0),
                                          Text(recipeProvider.getShowItem[i].country.name),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: 'Recipe by : ',
                                              style: TextStyle(
                                                color: Colors.black, 
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: '${recipeProvider.getShowItem[i].user.name}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.0
                                                  ),
                                                )
                                              ]
                                            ),
                                          )
                                        ]
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.0),
                                  RichText(
                                    text: TextSpan(
                                      text: 'Category : ',
                                      style: TextStyle(
                                        color: Colors.black, 
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: '${recipeProvider.getShowItem[i].category.title}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0
                                          ),
                                        )
                                      ]
                                    ),
                                  ),
                                ]
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    refresh: refresh,
                  );
                }
              ),
            )
          );
        }
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
    MyRecipe recipeProvider = Provider.of<MyRecipe>(context, listen: false);
    List<RecipeShowModelData> results = recipeProvider.getShowItem.where((item) => item.title.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, i) {
        return InkWell(
          onTap: () => {
            Navigator.of(context).pushNamed(
              '/detail-recipe',
              arguments: {
                "uuid": results[i].uuid,
                "title": results[i].title,
                "userId": results[i].user.uuid,
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
                        imageUrl: '$imagesRecipesUrl/${results[i].imageurl}',
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
                          Text('${results[i].portion} Portion'),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 0.0, left: 20.0, right: 20.0, bottom: 15.0),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.flag),
                            SizedBox(width: 6.0),
                            Text(results[i].country.name),
                          ],
                        ),
                        Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Recipe by : ',
                                style: TextStyle(
                                  color: Colors.black, 
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: '${results[i].user.name}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0
                                    ),
                                  )
                                ]
                              ),
                            )
                          ]
                        )
                      ],
                      ),
                      SizedBox(height: 10.0),
                       RichText(
                         text: TextSpan(
                           text: 'Category : ',
                           style: TextStyle(
                             color: Colors.black, 
                           ),
                           children: <TextSpan>[
                             TextSpan(
                               text: '${results[i].category.title}',
                               style: TextStyle(
                                 fontWeight: FontWeight.bold,
                                 fontSize: 16.0
                               ),
                             )
                           ]
                         ),
                       )
                    ]
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
    MyRecipe recipeProvider = Provider.of<MyRecipe>(context, listen: false);
    if(query.isEmpty) {
      return Container();
      // return ListView.builder(
      //   itemCount: recipeProvider.getShowItem.length,
      //   itemBuilder: (context, i) => Card(
      //     child: ListTile(
      //       onTap: () {
      //         Navigator.of(context).pushNamed(
      //           '/detail-recipe',
      //           arguments: {
      //             'uuid': recipeProvider.getShowItem[i].uuid,
      //             'title': recipeProvider.getShowItem[i].title,
      //             'userId': recipeProvider.getShowItem[i].user.uuid,
      //           }
      //         );
      //       },
      //       leading: CachedNetworkImage(
      //         width: 50.0,
      //         height: 50.0,
      //         imageUrl: '$imagesRecipesUrl/${recipeProvider.getShowItem[i].imageurl}',
      //         placeholder: (context, url) => Image.asset('assets/default-thumbnail.jpg'),
      //         errorWidget: (context, url, error) => Image.asset('assets/default-thumbnail.jpg'),
      //         fadeOutDuration: Duration(seconds: 1),
      //         fadeInDuration: Duration(seconds: 1),
      //       ),
      //       title: RichText(
      //         text: TextSpan(
      //           children: highlightOccurrences(recipeProvider.getShowItem[i].title, query),
      //           style: TextStyle(
      //             color: Colors.grey,
      //             fontWeight: FontWeight.bold
      //           ),
      //         )
      //       )
      //     ),
      //   ),
      // );
    }
    List<RecipeShowModelData> suggestionsList = recipeProvider.getShowItem.where((item) => item.title.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: suggestionsList.length,
      itemBuilder: (context, i) => Card(
        child: ListTile(
          onTap: () {
            Navigator.of(context).pushNamed(
              '/detail-recipe',
              arguments: {
                'uuid': suggestionsList[i].uuid,
                'title': suggestionsList[i].title,
                'userId': suggestionsList[i].user.uuid,
              }
            );
          },
          leading: CachedNetworkImage(
            width: 50.0,
            height: 50.0,
            imageUrl: '$imagesRecipesUrl/${suggestionsList[i].imageurl}',
            placeholder: (context, url) => Image.asset('assets/default-thumbnail.jpg'),
            errorWidget: (context, url, error) => Image.asset('assets/default-thumbnail.jpg'),
            fadeOutDuration: Duration(seconds: 1),
            fadeInDuration: Duration(seconds: 1),
          ),
          title: RichText(
            text: TextSpan(
              children: highlightOccurrences(suggestionsList[i].title, query),
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