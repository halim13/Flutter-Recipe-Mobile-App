import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/connectivity.service.dart';
import '../../providers/recipe/detail.dart';
import '../../widgets/favourites.item.dart';

class FavoritesScreen extends StatefulWidget {

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {

  Widget showError() {
    return Center(
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
        ],
      ),
    );
  }

  

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<RecipeDetail>(context, listen: false).getRecipeFavorite(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if(snapshot.hasError) {
          return showError();
        }
        return Consumer<RecipeDetail>(
          child: RefreshIndicator(
            onRefresh: () => Provider.of<RecipeDetail>(context, listen: false).refreshRecipeFavorite(),
            child: ListView(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: Column( 
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'There is no Favorites yet', 
                        style: TextStyle(
                          fontSize: 15.0
                        ),
                      )
                    ]
                  ),
                ),
              ],
            ),
          ),
          builder: (BuildContext context, RecipeDetail recipeProvider, Widget child) {
            if(recipeProvider.displayRecipeFavorite.length <= 0) {
              return child;
            }
            return RefreshIndicator(
              onRefresh: () => recipeProvider.refreshRecipeFavorite(),
              child: ListView.builder(
              itemCount: recipeProvider.displayRecipeFavorite.length,
                itemBuilder: (context, i) {
                  return ConnectivityService(
                    widget: FavoriteItem(
                    uuid: recipeProvider.displayRecipeFavorite[i].uuid,
                    title: recipeProvider.displayRecipeFavorite[i].title,
                    duration: recipeProvider.displayRecipeFavorite[i].duration,
                    imageurl: recipeProvider.displayRecipeFavorite[i].imageurl,
                    portion: recipeProvider.displayRecipeFavorite[i].portion,
                    categoryTitle: recipeProvider.displayRecipeFavorite[i].category.title,
                    username: recipeProvider.displayRecipeFavorite[i].user.name,
                    userId: recipeProvider.displayRecipeFavorite[i].user.uuid,
                    countryName: recipeProvider.displayRecipeFavorite[i].country.name,
                  )
                  );
                }
              ),
            );
          }
        );
      }
    );
  }
}
