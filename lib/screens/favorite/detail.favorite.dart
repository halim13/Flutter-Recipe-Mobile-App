import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/recipe.edit.dart';
import 'package:provider/provider.dart';
import 'package:quartet/quartet.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../constants/url.dart';
import '../preview.image.dart';
import '../../providers/auth.dart';
import '../recipe/edit.dart';

class RecipeDetailFavoriteScreen extends StatefulWidget {
  static const routeName = '/recipe-detail-favorite';

  @override
  _RecipeDetailFavoriteScreenState createState() => _RecipeDetailFavoriteScreenState();
}

class _RecipeDetailFavoriteScreenState extends State<RecipeDetailFavoriteScreen> {

  void edit() {
    Map<String, String> routeArgs = ModalRoute.of(context).settings.arguments;
    Navigator.of(context).pushNamed(
      EditRecipeScreen.routeName,
      arguments: routeArgs['uuid']
    );
  }

   Widget buildSectionTitle(BuildContext context, String text) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Text(text,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 17.0
        )
      ),
    );
  }

  Widget buildContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.all(10.0),
      width: double.infinity,
      child: child,
    );
  }


  @override
  Widget build(BuildContext context) {
    Map<String, String> routeArgs = ModalRoute.of(context).settings.arguments;
    RecipeEdit recipeProvider = Provider.of<RecipeEdit>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(titleCase(routeArgs['title'])),
        actions: [
          Consumer<Auth>(
            builder: (context, authProvider, child) => authProvider.isAuth ? IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.blue.shade700,
              ), 
              onPressed: edit
            ) : FutureBuilder(
              future: authProvider.tryAutoLogin(),
              builder: (ctx, snapshot) => Container()
            )
          )
        ],
      ),
      body: FutureBuilder(
        future: Provider.of<RecipeEdit>(context, listen: false).detail(routeArgs['uuid']),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator() 
            );
          }
          if(snapshot.hasError) {
            return Center(
              child: Text('Oops! Something went wrong! Please Try Again.'),
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: '$imagesRecipesUrl/${recipeProvider.recipeDetailDatas.recipes.first.imageUrl}',
                    imageBuilder: (context, imageProvider) => Container(
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
                  ) 
                ),
                buildSectionTitle(context, 'Bahan - bahan'),
                buildContainer(
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: recipeProvider.recipeDetailDatas.ingredientsGroup.length,
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                    itemBuilder: (context, i) => Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('- ${recipeProvider.recipeDetailDatas.ingredientsGroup[i].body}', 
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold
                            )
                          ),
                          SizedBox(height: 4.0),
                          ListView(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: List.generate(recipeProvider.recipeDetailDatas.ingredientsGroup[i].ingredients.length, (z) => Container(
                                child: Container(
                                  margin: EdgeInsets.only(left: 10.0),
                                  child: Text('- ${recipeProvider.recipeDetailDatas.ingredientsGroup[i].ingredients[z].body}',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      height: 1.75
                                    ) 
                                  )
                                )
                              )
                            )
                          ),
                        ],
                      )
                    )
                  ),
                ),
                buildSectionTitle(context, 'Langkah Memasak'),
                buildContainer(
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: recipeProvider.recipeDetailDatas.steps.length,
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                    itemBuilder: (context, i) => Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red.shade700,
                            child: Text('${i + 1}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              )
                            ),
                          ),
                          title: Text(
                            recipeProvider.recipeDetailDatas.steps[i].body,
                            style: TextStyle(
                              fontSize: 16.0,
                              height: 1.75
                            ),
                          ),
                        ),
                        Row(
                          children: List.generate(recipeProvider.recipeDetailDatas.steps[i].stepsImages.length, (z) => 
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (context) {
                                  return PreviewImageScreen(
                                    url: imagesStepsUrl,
                                    body: recipeProvider.recipeDetailDatas.steps[i].stepsImages[z].body
                                  );
                                })),
                                child: Container(
                                  child: CachedNetworkImage(
                                    width: 100.0,
                                    height: 100.0,
                                    imageUrl: '$imagesStepsUrl/${recipeProvider.recipeDetailDatas.steps[i].stepsImages[z].body}',
                                    placeholder: (context, url) => Image.asset('assets/default-thumbnail.jpg'),
                                    errorWidget: (context, url, error) => Image.asset('assets/default-thumbnail.jpg'),
                                    fadeOutDuration: Duration(seconds: 1),
                                    fadeInDuration: Duration(seconds: 1),
                                  )
                                ),
                              ),
                            )
                          ) 
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
      floatingActionButton: Consumer<RecipeEdit>(
        builder: (context, recipeProvider, ch) {
          return FloatingActionButton(
            backgroundColor: Colors.yellow.shade700,
            foregroundColor: Colors.black,
            child: Icon(recipeProvider.isRecipeFavorite(routeArgs['uuid'], recipeProvider.favourite) ? Icons.star : Icons.star_border),
            onPressed: () => recipeProvider.toggleFavourite(routeArgs['uuid'], recipeProvider.favourite, context)
          );
        },
      )
    );
  }
  
}