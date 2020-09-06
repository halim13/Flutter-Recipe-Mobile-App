import 'package:flutter/material.dart';
import 'package:quartet/quartet.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../constants/url.dart';
import '../../providers/auth/auth.dart';
import '../../providers/recipe/detail.dart';
import '../../providers/user/user.dart';
import '../preview.image.dart';

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
        "recipeId": recipeId,
        "categoryId": categoryId
      }
    ).then((_title) {
      if(_title != null) {
        setState(() {
          title = _title;
        });
      }
    });
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
  void didChangeDependencies() {
    Map<String, String> routeArgs = ModalRoute.of(context).settings.arguments;
    String _title = routeArgs["title"];
    if(_title != null) {
      title = _title;
    }
    super.didChangeDependencies();
  }
  Widget build(BuildContext context) {
    Map<String, String> routeArgs = ModalRoute.of(context).settings.arguments;
    String recipeId = routeArgs["uuid"];
    String userId = routeArgs["userId"];

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
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator() 
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
          return Consumer<RecipeDetail>(
            builder: (BuildContext context, RecipeDetail recipeProvider, Widget child) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 300.0,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: '$imagesRecipesUrl/${recipeProvider.recipeDetail.first.imageurl}',
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
                      '${recipeProvider.recipeDetail.first.title}',
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
                            Text('${recipeProvider.getRecipeDetail.first.duration} min'),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.fastfood),
                            SizedBox(width: 6.0),
                            Text('${recipeProvider.getRecipeDetail.first.portion} Portion'),
                          ],
                        )
                      ],
                    )
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 30.0),
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
                                Text(recipeProvider.getRecipeDetail.first.country.name),
                              ]
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
                                        text: '${recipeProvider.getRecipeDetail.first.user.name}',
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
                                text: '${recipeProvider.getRecipeDetail.first.category.title}',
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
                  Center(
                    child: buildSectionTitle(context, 'Ingredients')
                  ),
                  buildContainer(
                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: recipeProvider.getIngredientsGroupDetail.length,
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                      itemBuilder: (context, i) => Container(
                        margin: EdgeInsets.only(bottom: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('- ${recipeProvider.getIngredientsGroupDetail[i].body}', 
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold
                              )
                            ),
                            SizedBox(height: 4.0),
                            ListView(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              children: List.generate(recipeProvider.getIngredientsGroupDetail[i].ingredients.length, (z) => Container(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 10.0),
                                    child: Text('- ${recipeProvider.getIngredientsGroupDetail[i].ingredients[z].body}',
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
                    child: buildSectionTitle(context, 'How to Cook')
                  ),
                  buildContainer(
                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: recipeProvider.getStepsDetail.length,
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
                              recipeProvider.getStepsDetail[i].body,
                              style: TextStyle(
                                fontSize: 16.0,
                                height: 1.75
                              ),
                            ),
                          ),
                          Row(
                            children: List.generate(recipeProvider.getStepsDetail[i].stepsImages.length, (z) => 
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context, 
                                    MaterialPageRoute(builder: (context) {
                                    return PreviewImageScreen(
                                      url: imagesStepsUrl,
                                      body: recipeProvider.getStepsDetail[i].stepsImages[z].body
                                    );
                                  })),
                                  child: Container(
                                    child: CachedNetworkImage(
                                      width: 100.0,
                                      height: 100.0,
                                      imageUrl: '$imagesStepsUrl/${recipeProvider.getStepsDetail[i].stepsImages[z].body}',
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
            ),
          );
        }
      ),
      floatingActionButton: Consumer<Auth>( 
        builder: (BuildContext context, Auth authProvider, Widget child) {
          return authProvider.isAuth 
          ? Consumer<RecipeDetail>(
              builder: (context, recipeProvider, ch) {
                return FloatingActionButton(
                  elevation: 0.0,
                  backgroundColor: Colors.yellow.shade700,
                  foregroundColor: Colors.black,
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
