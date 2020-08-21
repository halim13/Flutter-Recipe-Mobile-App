import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe.detail.dart';
import '../widgets/recipe.item.dart';

class FavoritesScreen extends StatelessWidget {

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
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: Column( 
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Belum ada resep kesukaan kamu.', 
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
          builder: (context, recipeProvider, child) {
            if(recipeProvider.displayRecipeFavourite.length <= 0) {
              return child;
            }
            return RefreshIndicator(
              onRefresh: () => recipeProvider.refreshRecipeFavourite(),
              child: ListView.builder(
              itemCount: recipeProvider.displayRecipeFavourite.length,
                itemBuilder: (context, index) {
                  return RecipeItem(
                    id: recipeProvider.displayRecipeFavourite[index].id,
                    uuid: recipeProvider.displayRecipeFavourite[index].uuid,
                    title: recipeProvider.displayRecipeFavourite[index].title,
                    imageUrl: recipeProvider.displayRecipeFavourite[index].imageUrl,
                    duration: recipeProvider.displayRecipeFavourite[index].duration.toString(),
                    affordability: recipeProvider.displayRecipeFavourite[index].affordability,
                    complexity: recipeProvider.displayRecipeFavourite[index].complexity,
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
