import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/constants/connection.dart';
import 'package:provider/provider.dart';
import '../providers/meals_detail.dart';
import './edit_recipe_screen.dart';

class MealDetailScreen extends StatefulWidget {
  static const routeName = '/meal-detail';

  @override
  _MealDetailScreenState createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {

  void edit() {
    final mealId = ModalRoute.of(context).settings.arguments;
    Navigator.of(context).pushNamed(
      EditRecipeScreen.routeName,
      arguments: mealId
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
      height: 150,
      width: 300,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    const baseurl = 'http://192.168.43.226:5000/images/recipe/';
    final mealId = ModalRoute.of(context).settings.arguments;
    final provider = Provider.of<MealsDetail>(context, listen: false);
    return FutureBuilder(
      future: Provider.of<MealsDetail>(context, listen: false).detail(mealId),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text("")
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if(snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text(provider.data.meals.first.title),
            ),
            body: Center(
              child: Text('Oops! Something went wrong! Please Try Again.'),
            )
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(provider.data.meals.first.title),
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
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  child: Image.network('$imagesRecipesUrl/${provider.data.meals.first.imageUrl}',
                    fit: BoxFit.cover,
                  ),
                ),
                buildSectionTitle(context, 'Ingredients'),
                buildContainer(
                  ListView.builder(
                    itemCount: provider.data.ingredients.length,
                    itemBuilder: (ctx, index) => Card(
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
                    itemBuilder: (context, index) => Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            child: Text('# ${(index + 1)}'),
                          ),
                          title: Text(
                            provider.data.steps[index].body,
                          ),
                        ),
                        Divider()
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: Consumer<MealsDetail>(
            builder: (context, value, ch) {
              return FloatingActionButton(
                backgroundColor: Colors.yellow.shade700,
                foregroundColor: Colors.black,
                child: Icon(value.isMealFavorite(mealId) ? Icons.star : Icons.star_border),
                onPressed: () => value.toggleFavourite(mealId)
              );
            },
          )
        );
      },
    );
  }
}
