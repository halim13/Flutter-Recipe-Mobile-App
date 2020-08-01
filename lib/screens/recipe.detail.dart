import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/screens/preview.image.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/url.dart';
import '../providers/recipe.detail.dart';
import './edit.recipe.dart';

class RecipeDetailScreen extends StatefulWidget {
  static const routeName = '/recipe-detail';

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {

  void edit() {
    final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
    Navigator.of(context).pushNamed(
      EditRecipeScreen.routeName,
      arguments: routeArgs['uuid']
    );
  }

  Widget buildSectionTitle(BuildContext context, String text) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Text(text,
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }

  Widget buildContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      height: 150.0,
      width: double.infinity,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
    final provider = Provider.of<RecipeDetail>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(routeArgs['title']),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit,
              color: Colors.blue,
            ), 
            onPressed: edit
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
                  child: Image.network('$imagesRecipesUrl/${provider.data.recipes.first.imageUrl}',
                    fit: BoxFit.cover,
                  ),
                ),
                buildSectionTitle(context, 'Ingredients'),
                buildContainer(
                  ListView.builder(
                    itemCount: provider.data.ingredients.length,
                    itemBuilder: (context, index) => Card(
                      color: Theme.of(context).accentColor,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        child: Text(provider.data.ingredients[index].body)),
                      ),
                  ),
                ),
                buildSectionTitle(context, 'Steps'),
                buildContainer(
                  ListView.builder(
                    itemCount: provider.data.steps.length,
                    itemBuilder: (context, i) => Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            child: Text('${i + 1}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 19.0,
                              )
                            ),
                          ),
                          title: Text(
                            provider.data.steps[i].body,
                          ),
                        ),
                        Row(
                          children: List.generate(provider.data.steps[i].stepsImages.length, (z) => 
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) {
                                  return PreviewImageScreen(body: provider.data.steps[i].stepsImages[z].body);
                                })),
                                child: Container(
                                  child: CachedNetworkImage(
                                    width: 100.0,
                                    height: 100.0,
                                    imageUrl: '$imagesStepsUrl/${provider.data.steps[i].stepsImages[z].body}',
                                    placeholder: (context, url) => const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                  )
                                ),
                              ),
                            )
                          ) 
                        ),
                        Divider()
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
      floatingActionButton: Consumer<RecipeDetail>(
        builder: (context, value, ch) {
          return FloatingActionButton(
            backgroundColor: Colors.yellow.shade700,
            foregroundColor: Colors.black,
            child: Icon(value.isRecipeFavorite(routeArgs['uuid'], value.favourite) ? Icons.star : Icons.star_border),
            onPressed: () => value.toggleFavourite(routeArgs['uuid'], value.favourite)
          );
        },
      )
    );
  }
}
