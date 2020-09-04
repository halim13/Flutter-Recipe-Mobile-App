import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quartet/quartet.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../constants/url.dart';
import '../../providers/recipe/my.recipe.dart';
import '../../screens/profile/view.dart';

class MyRecipeScreen extends StatefulWidget {
  @override
  _MyRecipeScreenState createState() => _MyRecipeScreenState();
}

class _MyRecipeScreenState extends State<MyRecipeScreen> {
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        Provider.of<MyRecipe>(context, listen: false).getShow(5);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void selectRecipe(
    BuildContext context, 
    String uuid, 
    String title, 
    String portion,
    String duration,
    String userId,
    String name
  ) {
    Navigator.of(context).pushNamed(
      'detail-recipe',
      arguments: {
        'uuid': uuid,
        'title': title,
        'userId': userId,
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Recipes')
      ),
      body: FutureBuilder(
        future: Provider.of<MyRecipe>(context, listen: false).getShow(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if(snapshot.hasError) {
            return Consumer<MyRecipe>(
            builder: (context, userProvider, child) =>
              Center(
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
              ),
            );
          }
          return Consumer<MyRecipe>(
            child: Center(
              child: Text('There is no Recipes yet'),
            ),
            builder: (BuildContext context, MyRecipe recipeProvider, Widget child) => recipeProvider.getShowItem.length <= 0 ? child :
            RefreshIndicator(
              onRefresh: () => recipeProvider.refreshRecipe(),
              child: ListView.builder(
              controller: controller,
              itemCount: recipeProvider.getShowItem.length,
              itemBuilder: (context, i) {
                if(i == recipeProvider.getShowItem.length) 
                  return CircularProgressIndicator();
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)
                    ),
                    elevation: 4.0,
                    margin: EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            InkWell(
                              onTap: () {
                                selectRecipe(
                                  context, 
                                  recipeProvider.getShowItem[i].uuid,
                                  recipeProvider.getShowItem[i].title, 
                                  recipeProvider.getShowItem[i].portion,
                                  recipeProvider.getShowItem[i].duration, 
                                  recipeProvider.getShowItem[i].userId,
                                  recipeProvider.getShowItem[i].name
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15.0),
                                  topRight: Radius.circular(15.0),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: '$imagesRecipesUrl/${recipeProvider.getShowItem[i].imageurl}',
                                  imageBuilder: (context, imageProvider) => Container(
                                    width: double.infinity,
                                    height: 250.0,
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
                                ),
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
                                child: Text(
                                  titleCase(recipeProvider.getShowItem[i].title),
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
                                  Text('${recipeProvider.getShowItem[i].duration} min'),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.fastfood),
                                  SizedBox(width: 6.0),
                                  Text('${recipeProvider.getShowItem[i].portion} Portion'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ViewProfileScreen(recipeProvider.getShowItem[i].userId, recipeProvider.getShowItem[i].name)),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.only(top: 0.0, left: 0.0, right: 20.0, bottom: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.people),
                                SizedBox(width: 6),
                                RichText(
                                  text: TextSpan(
                                    text: 'Recipe by : ',
                                    style: TextStyle(
                                      color: Colors.black, 
                                      fontSize: 16.0
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: '${recipeProvider.getShowItem[i].name}',
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
                        ),
                      ],
                    ),
                  );
                }
              ),
            )
          );
        }
      )
    );
  }
}