import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meals.dart';

class MealDetailScreen extends StatefulWidget {
  static const routeName = '/meal-detail';

  @override
  _MealDetailScreenState createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {

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
    final mealId = ModalRoute.of(context).settings.arguments;
    return FutureBuilder(
      future: Provider.of<Meals>(context, listen: false).detail(mealId),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return Consumer<Meals>(
            builder: (context, value, ch) {
              return Scaffold(
                appBar: AppBar(
                  title: Text('')
                ),
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          );
        }
        if(snapshot.hasError) {
          return Consumer<Meals>(
            builder: (context, value, ch) { 
              return Scaffold(
                appBar: AppBar(
                  title: Text(value.data.meals.first.title),
                ),
                body: Center(
                  child: Text('Oops! Something went wrong! Please Try Again.'),
                )
              );
            }
          );
        }
        return Consumer<Meals>(
          builder: (context, value, child) {
            return Scaffold(
              appBar: AppBar(
                title: Text(value.data.meals.first.title),
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 300,
                      width: double.infinity,
                      child: Image.network(
                        value.data.meals.first.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    buildSectionTitle(context, 'Ingredients'),
                    buildContainer(
                      ListView.builder(
                        itemCount: value.data.ingredients.length,
                        itemBuilder: (ctx, index) => Card(
                          color: Theme.of(context).accentColor,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 10,
                            ),
                            child: Text(value.data.ingredients[index].body)),
                          ),
                      ),
                    ),
                    buildSectionTitle(context, 'Steps'),
                    buildContainer(
                      ListView.builder(
                        itemCount: value.data.steps.length,
                        itemBuilder: (context, index) => Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                child: Text('# ${(index + 1)}'),
                              ),
                              title: Text(
                                value.data.steps[index].body,
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
              floatingActionButton: FloatingActionButton(
                child: Icon(value.isMealFavorite(mealId) ? Icons.star : Icons.star_border),
                onPressed: () => value.toggleFavourite(mealId)
              )
            );
          }
        );
      },
    );
  }
}
