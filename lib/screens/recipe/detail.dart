import 'package:flutter/material.dart';
import 'package:quartet/quartet.dart';
import 'package:provider/provider.dart';

import '../../helpers/connectivity.service.dart';
import '../../providers/auth/auth.dart';
import '../../providers/recipe/detail.dart';
import '../../providers/user/user.dart';
import '../../widgets/detail.recipe.item.dart';

class RecipeDetailScreen extends StatefulWidget {
  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  String title;

  void edit() {
    Map<String, String> routeArgs = ModalRoute.of(context).settings.arguments;
    String recipeId = routeArgs['uuid'];
    String categoryId = routeArgs['categoryId'];
    Navigator.of(context).pushNamed(
      '/edit-recipe',
      arguments: { 
        'recipeId': recipeId,
        'categoryId': categoryId
      }
    ).then((_title) {
      if(_title != null) {
        setState(() {
          title = _title;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    Map<String, String> routeArgs = ModalRoute.of(context).settings.arguments;
    String _title = routeArgs['title'];
    if(_title != null) {
      title = _title;
    }
    super.didChangeDependencies();
  }
  Widget build(BuildContext context) {
    Map<String, String> routeArgs = ModalRoute.of(context).settings.arguments;
    String recipeId = routeArgs['uuid'];
    String userId = routeArgs['userId'];

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

    return Scaffold(
      appBar: AppBar(
        title: Text(titleCase(title)),
        actions: [
          Consumer<Auth>(
            builder: (BuildContext context, Auth authProvider, Widget child) => authProvider.isAuth 
            ? Consumer<User>(
              builder: (BuildContext context, User userProvider, Widget child) => userProvider.isUserRecipe(userId) 
              != null 
                ? userProvider.isUserRecipeCheck
                  ? IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.blue.shade700,
                      ), 
                      onPressed: edit
                    ) 
                  : Container()
                : Container()
              )
            : FutureBuilder(
              future: authProvider.tryAutoLogin(),
              builder: (ctx, snapshot) => Container()
            )
          )
        ],
      ),
      body: FutureBuilder(
        future: Provider.of<RecipeDetail>(context, listen: false).detail(recipeId),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator() 
            );
          }
          if(snapshot.hasError) {
            return showError();
          }
          return Consumer<RecipeDetail>(
            builder: (BuildContext context, RecipeDetail recipeProvider, Widget child) {
              return ConnectivityService(
                widget: DetailRecipeItem(  
                  imageurl: recipeProvider.getRecipeDetail.first.imageurl,
                  title: recipeProvider.getRecipeDetail.first.title,
                  duration: recipeProvider.getRecipeDetail.first.duration,
                  portion: recipeProvider.getRecipeDetail.first.portion,
                  countryName: recipeProvider.getRecipeDetail.first.country.name,
                  userName: recipeProvider.getRecipeDetail.first.user.name,
                  categoryTitle: recipeProvider.getRecipeDetail.first.category.title,
                  getIngredientsGroupDetail: recipeProvider.getIngredientsGroupDetail,
                  getStepsDetail: recipeProvider.getStepsDetail,
                ),
              );
            }
          );
        }
      ),
      floatingActionButton: Consumer<Auth>( 
        builder: (BuildContext context, Auth authProvider, Widget child) {
          return authProvider.isAuth 
          ? Consumer<RecipeDetail>(
              builder: (context, recipeProvider, ch) {
                return FloatingActionButton(
                  heroTag: UniqueKey(),
                  backgroundColor: Colors.yellow.shade700,
                  foregroundColor: Colors.black,
                  elevation: 0.0,
                  child: Icon(recipeProvider.isRecipeFavorite(recipeId, recipeProvider.favorite) ? Icons.star : Icons.star_border),
                  onPressed: () => recipeProvider.toggleFavorite(recipeId, recipeProvider.favorite, context)
                );
              },
            ) 
          : FutureBuilder(
            future: authProvider.tryAutoLogin(),
            builder: (ctx, snapshot) => Container()
          );
        }
      )
    );
  }
}
