import 'package:flutter/material.dart';
import 'package:quartet/quartet.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../preview.image.dart';
import '../../constants/url.dart';
import '../../providers/auth/auth.dart';
import '../../providers/recipe/detail.dart';
import '../../providers/user/user.dart';
import './edit.dart';

class RecipeDetailScreen extends StatefulWidget {
  static const routeName = '/recipe-detail';

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {

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
    RecipeDetail recipeProvider = Provider.of<RecipeDetail>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(titleCase(routeArgs['title'])),
        actions: [
          Consumer<Auth>(
            builder: (BuildContext context, Auth authProvider, Widget child) => authProvider.isAuth 
            ? Consumer<User>(
              builder: (BuildContext context, User userProvider, Widget child) => userProvider.isUserRecipe(routeArgs["userId"]) 
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
        future: Provider.of<RecipeDetail>(context, listen: false).detail(routeArgs['uuid']),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator() 
            );
          }
          if(snapshot.hasError) {
           
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 300.0,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: '$imagesRecipesUrl/${recipeProvider.data.recipes.first.imageUrl}',
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
                Container(
                  margin: EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0, bottom: 5.0),
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    '${routeArgs['title']}',
                    style: TextStyle(
                      fontSize: 19.0,
                    ),
                  )
                ), 
                Container(
                  margin: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.schedule),
                          SizedBox(width: 6.0),
                          Text('${routeArgs['duration']} min'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.fastfood),
                          SizedBox(width: 6.0),
                          Text('${routeArgs['portion']} Porsi'),
                        ],
                      )
                    ],
                  )
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.people),
                      SizedBox(width: 6),
                      RichText(
                        text: TextSpan(
                          text: 'Dibuat oleh : ',
                          style: TextStyle(
                            color: Colors.black, 
                            fontSize: 16.0
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: '${routeArgs['name']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0
                              ),
                            )
                          ]
                        ),
                      )
                    ],
                  ),
                ),
                Center(
                  child: buildSectionTitle(context, 'Bahan - bahan')
                ),
                buildContainer(
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: recipeProvider.data.ingredientsGroup.length,
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                    itemBuilder: (context, i) => Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('- ${recipeProvider.data.ingredientsGroup[i].body}', 
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold
                            )
                          ),
                          SizedBox(height: 4.0),
                          ListView(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: List.generate(recipeProvider.data.ingredientsGroup[i].ingredients.length, (z) => Container(
                                child: Container(
                                  margin: EdgeInsets.only(left: 10.0),
                                  child: Text('- ${recipeProvider.data.ingredientsGroup[i].ingredients[z].body}',
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
                Center(
                  child: buildSectionTitle(context, 'Langkah Memasak')
                ),
                buildContainer(
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: recipeProvider.data.steps.length,
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
                            recipeProvider.data.steps[i].body,
                            style: TextStyle(
                              fontSize: 16.0,
                              height: 1.75
                            ),
                          ),
                        ),
                        Row(
                          children: List.generate(recipeProvider.data.steps[i].stepsImages.length, (z) => 
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (context) {
                                  return PreviewImageScreen(
                                    url: imagesStepsUrl,
                                    body: recipeProvider.data.steps[i].stepsImages[z].body
                                  );
                                })),
                                child: Container(
                                  child: CachedNetworkImage(
                                    width: 100.0,
                                    height: 100.0,
                                    imageUrl: '$imagesStepsUrl/${recipeProvider.data.steps[i].stepsImages[z].body}',
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
      floatingActionButton: Consumer<Auth>( 
        builder: (BuildContext context, Auth authProvider, Widget child) {
          return authProvider.isAuth ? Consumer<RecipeDetail>(
            builder: (context, recipeProvider, ch) {
              return FloatingActionButton(
                backgroundColor: Colors.yellow.shade700,
                foregroundColor: Colors.black,
                child: Icon(recipeProvider.isRecipeFavorite(routeArgs['uuid'], recipeProvider.favorite) ? Icons.star : Icons.star_border),
                onPressed: () => recipeProvider.toggleFavorite(routeArgs['uuid'], recipeProvider.favorite, context)
              );
            },
          ) : FutureBuilder(
            future: authProvider.tryAutoLogin(),
            builder: (ctx, snapshot) => Container()
          );
        }
      )
    );
  }
}
