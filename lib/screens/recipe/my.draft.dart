import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quartet/quartet.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../helpers/highlight.occurences.dart';
import '../../models/RecipeDraft.dart';
import '../../constants/url.dart';
import '../../providers/recipe/my.draft.dart';
import '../../screens/profile/view.dart';

class MyDraftScreen extends StatefulWidget {
  @override
  _MyDraftScreenState createState() => _MyDraftScreenState();
}

class _MyDraftScreenState extends State<MyDraftScreen> {
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        Provider.of<MyDraft>(context, listen: false).getRecipesDraft(5);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void selectRecipe(
    BuildContext context, 
    String uuid, 
    String title,
    String userId
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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Drafts'),
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
        future: Provider.of<MyDraft>(context, listen: false).getRecipesDraft(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if(snapshot.hasError) {
            return  Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150.0,
                      child: Image.asset('assets/no-network.png')
                    ),
                    SizedBox(height: 15.0),
                    Text('Bad Connection or Server Unreachable',
                      style: TextStyle(
                        fontSize: 16.0
                      ),
                    ),
                    SizedBox(height: 10.0),
                    GestureDetector(
                      child: Text('Try Again',
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
              );
          }
          return Consumer<MyDraft>(
            child: Center(
              child: Text('There is no Drafts yet'),
            ),
            builder: (BuildContext context, MyDraft recipeProvider, Widget child) => recipeProvider.getRecipesDraftItem.length <= 0 ? child :
            RefreshIndicator(
              onRefresh: () => recipeProvider.refreshRecipesDraft(),
              child: ListView.builder(
              controller: controller,
              itemCount: recipeProvider.getRecipesDraftItem.length,
              itemBuilder: (context, i) {
                if(i == recipeProvider.getRecipesDraftItem.length) 
                  return CircularProgressIndicator();
                  return Card(
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
                                selectRecipe(
                                  context, 
                                  recipeProvider.getRecipesDraftItem[i].uuid,
                                  recipeProvider.getRecipesDraftItem[i].title, 
                                  recipeProvider.getRecipesDraftItem[i].user.uuid
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15.0),
                                  topRight: Radius.circular(15.0),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: '$imagesRecipesUrl/${recipeProvider.getRecipesDraftItem[i].imageurl}',
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
                                  titleCase(recipeProvider.getRecipesDraftItem[i].title),
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
                                  Text('${recipeProvider.getRecipesDraftItem[i].duration} min'),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.fastfood),
                                  SizedBox(width: 6.0),
                                  Text('${recipeProvider.getRecipesDraftItem[i].portion} Portion'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ViewProfileScreen(recipeProvider.getRecipesDraftItem[i].user.uuid, recipeProvider.getRecipesDraftItem[i].user.name)),
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
                                      Text(recipeProvider.getRecipesDraftItem[i].country.name),
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
                                              text: '${recipeProvider.getRecipesDraftItem[i].user.name}',
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
                                      text: '${recipeProvider.getRecipesDraftItem[i].category.title}',
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
                        ),
                      ],
                    ),
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
    MyDraft recipeProvider = Provider.of<MyDraft>(context, listen: false);
    List<RecipeDraftModelData> results = recipeProvider.getRecipesDraftItem.where((item) => item.title.toLowerCase().contains(query.toLowerCase())).toList();
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
    MyDraft recipeProvider = Provider.of<MyDraft>(context, listen: false);
    if(query.isEmpty) {
      return Container();
      // return ListView.builder(
      //   itemCount: recipeProvider.getRecipesDraftItem.length,
      //   itemBuilder: (context, i) => Card(
      //     child: ListTile(
      //       onTap: () {
      //         Navigator.of(context).pushNamed(
      //           '/detail-recipe',
      //           arguments: {
      //             'uuid': recipeProvider.getRecipesDraftItem[i].uuid,
      //             'title': recipeProvider.getRecipesDraftItem[i].title,
      //             'userId': recipeProvider.getRecipesDraftItem[i].user.uuid,
      //           }
      //         );
      //       },
      //       leading: CachedNetworkImage(
      //         width: 50.0,
      //         height: 50.0,
      //         imageUrl: '$imagesRecipesUrl/${recipeProvider.getRecipesDraftItem[i].imageurl}',
      //         placeholder: (context, url) => Image.asset('assets/default-thumbnail.jpg'),
      //         errorWidget: (context, url, error) => Image.asset('assets/default-thumbnail.jpg'),
      //         fadeOutDuration: Duration(seconds: 1),
      //         fadeInDuration: Duration(seconds: 1),
      //       ),
      //       title: RichText(
      //         text: TextSpan(
      //           children: highlightOccurrences(recipeProvider.getRecipesDraftItem[i].title, query),
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
    List<RecipeDraftModelData> suggestionsList = recipeProvider.getRecipesDraftItem.where((item) => item.title.toLowerCase().contains(query.toLowerCase())).toList();
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