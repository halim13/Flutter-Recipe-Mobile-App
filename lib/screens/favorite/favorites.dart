import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/recipe/detail.dart';
import '../../widgets/recipe.item.dart';

class FavoritesScreen extends StatefulWidget {

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<RecipeDetail>(context, listen: false).getRecipeFavorite(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if(snapshot.hasError) {
          return Center(
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
          );
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
                        'Belum ada favorit', 
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
            if(recipeProvider.displayRecipeFavorite.length <= 0) {
              return child;
            }
            return RefreshIndicator(
              onRefresh: () => recipeProvider.refreshRecipeFavorite(),
              child: ListView.builder(
              itemCount: recipeProvider.displayRecipeFavorite.length,
                itemBuilder: (context, i) {
                  return RecipeItem(
                    id: recipeProvider.displayRecipeFavorite[i].id,
                    uuid: recipeProvider.displayRecipeFavorite[i].uuid,
                    title: recipeProvider.displayRecipeFavorite[i].title,
                    duration: recipeProvider.displayRecipeFavorite[i].duration,
                    imageUrl: recipeProvider.displayRecipeFavorite[i].imageUrl,
                    userId: recipeProvider.displayRecipeFavorite[i].userId,
                    portion: recipeProvider.displayRecipeFavorite[i].portion,
                    name: recipeProvider.displayRecipeFavorite[i].name
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
