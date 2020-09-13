import 'package:flutter/material.dart';
import 'package:quartet/quartet.dart';
import 'package:provider/provider.dart';

import '../../providers/auth/auth.dart';
import '../../providers/recipe/detail.dart';
import '../../providers/user/user.dart';
import '../../helpers/connectivity.service.dart';
import '../../helpers/show.error.dart';
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
  refresh() {
    setState((){});
  }
  @override
  Widget build(BuildContext context) {
    Map<String, String> routeArgs = ModalRoute.of(context).settings.arguments;
    String recipeId = routeArgs['uuid'];
    String userId = routeArgs['userId'];

   
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
            return ShowError(
              notifyParent: refresh,
            );
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
                refresh: refresh,
              );
            }
          );
        }
      ),
      floatingActionButton: Consumer<Auth>( 
        builder: (BuildContext context, Auth authProvider, Widget child) {
          return authProvider.isAuth 
          ? Consumer<RecipeDetail>(
              builder: (BuildContext context, RecipeDetail recipeProvider, Widget child) {
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
            builder: (BuildContext context, AsyncSnapshot snapshot) => Container()
          );
        }
      )
    );
  }
}
