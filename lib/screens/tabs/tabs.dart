import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';


import '../../constants/url.dart';
import '../../helpers/highlight.occurences.dart';
import '../../widgets/main.drawer.dart';
import '../../providers/auth/auth.dart';
import '../../providers/recipe/detail.dart';
import '../../providers/custom/bottom_navy_bar.dart';
import '../../models/RecipeFavorite.dart';
import '../profile/profile.dart';
import '../profile/edit.dart';
import '../favorite/favorites.dart';
import '../recipe/categories.dart';

class TabsScreen extends StatefulWidget {

  @override
  TabsScreenState createState() => TabsScreenState();
}

class TabsScreenState extends State<TabsScreen> {
  List<Map<String, Object>> pages;
  int selectedPageIndex = 0;

  @override
  void initState() {
    pages = [
      {
        'page': CategoriesScreen(),
        'title': 'Categories',
      },
      {
        'page': FavoritesScreen(),
        'title': 'Favorites',
      },
      {
        'page': ProfileScreen(),
        'title': 'Profile',
      },
    ];
    super.initState();
  }

  void selectPage(int index) {
    setState(() {
      selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pages[selectedPageIndex]['title']),
        actions: [
          if(selectedPageIndex == 1)
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context, 
                delegate: DataSearch()
              );
            }
          ),
          if(selectedPageIndex == 2)
          Consumer<Auth>(
            builder: (context, authProvider, child) => authProvider.isAuth 
            ? IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Colors.blue.shade700,
                ), 
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return EditProfileScreen();
                    })
                  );
                },
              ) 
            : FutureBuilder(
              future: authProvider.tryAutoLogin(),
              builder: (ctx, snapshot) => Container()
            )
          )
        ],
      ),
      body: pages[selectedPageIndex]['page'],
      drawer: onlyCategoriesDrawer(selectedPageIndex),
      bottomNavigationBar: BottomNavyBar( 
        selectedIndex: selectedPageIndex,
        showElevation: false, 
        onItemSelected: (index) => setState(() {
          selectedPageIndex = index;
        }),
        items: [
          BottomNavyBarItem(
          icon: Icon(Icons.fastfood),
          title: Text('Categories'),
          activeColor: Colors.red.shade700,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.star),
            title: Text('Favorites'),
            activeColor: Colors.yellow.shade700
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.account_circle),
            title: Text('Profile'),
            activeColor: Colors.blue.shade700,
          ),
        ],
      ),
    );
  }

  Widget onlyCategoriesDrawer(int index) {
    if(index == 0) {
      return MainDrawer();
    }
    return null;
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
    RecipeDetail recipeProvider = Provider.of<RecipeDetail>(context, listen: false);
    List<RecipeFavoriteModelData> results = recipeProvider.displayRecipeFavorite.where((item) => item.title.toLowerCase().contains(query.toLowerCase())).toList();
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
    RecipeDetail recipeProvider = Provider.of<RecipeDetail>(context, listen: false);
    if(query.isEmpty) {
      return Container();
    }
    List<RecipeFavoriteModelData> suggestionsList = recipeProvider.displayRecipeFavorite.where((item) => item.title.toLowerCase().contains(query.toLowerCase())).toList();
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

