import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './recipe.detail.dart';
import '../providers/recipe.detail.dart';
import '../widgets/recipe.item.dart';

class FavoritesScreen extends StatelessWidget {

  void selectMeal(BuildContext context, String uuid) {
    Navigator.of(context).pushNamed(
      RecipeDetailScreen.routeName,
      arguments: uuid,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipeDetail>(context, listen: false);
    return FutureBuilder(
      future: Provider.of<RecipeDetail>(context, listen: false).getRecipeFavourite(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if(snapshot.hasError) {
          return Center(
            child: Center(
              child: Text('Oops! Something went wrong! Please try again.'),
            )
          );
        }
        return Consumer<RecipeDetail>(
          child: RefreshIndicator(
            onRefresh: () => provider.refreshRecipeFavourite(),
            child: ListView(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: Column( 
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text('You have no favorites yet.')
                    ]
                  ),
                ),
              ],
            ),
          ),
          builder: (context, value, ch) {
            if(value.displayRecipeFavourite.length <= 0) {
              return ch;
            }
            return RefreshIndicator(
              onRefresh: () => value.refreshRecipeFavourite(),
              child: ListView.builder(
              itemCount: value.displayRecipeFavourite.length,
                itemBuilder: (context, index) {
                  return RecipeItem(
                    uuid: value.displayRecipeFavourite[index].uuid,
                    title: value.displayRecipeFavourite[index].title,
                    imageUrl: value.displayRecipeFavourite[index].imageUrl,
                    duration: value.displayRecipeFavourite[index].duration,
                    affordability: value.displayRecipeFavourite[index].affordability,
                    complexity: value.displayRecipeFavourite[index].complexity,
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
