import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meals_detail.dart';
import '../screens/meal_detail_screen.dart';
import '../widgets/meal_item.dart';

class FavoritesScreen extends StatelessWidget {

   void selectMeal(BuildContext context, String id) {
    Navigator.of(context).pushNamed(
      MealDetailScreen.routeName,
      arguments: id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MealsDetail>(context, listen: false);
    return FutureBuilder(
      future: Provider.of<MealsDetail>(context, listen: false).getMealsFavourite(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if(snapshot.hasError) {
          return Center(
            child: Center(
              child: Text('Oops! Something went wrong! Please try again.'),
            )
          );
        }
        return Consumer<MealsDetail>(
          child: RefreshIndicator(
            onRefresh: () => provider.refreshMealsFavourite(),
            child: ListView(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: Column( 
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text('You have no favorites yet.')
                    ]
                  ),
                ),
              ],
            ),
          ),
          builder: (context, mealsdetail, ch) {
            if(mealsdetail.mealsFavouriteItems.length <= 0) {
              return ch;
            }
            return RefreshIndicator(
              onRefresh: () => mealsdetail.refreshMealsFavourite(),
              child: ListView.builder(
              itemCount: mealsdetail.mealsFavouriteItems.length,
                itemBuilder: (context, index) {
                  return MealItem(
                    id: mealsdetail.mealsFavouriteItems[index].id.toString(),
                    title: mealsdetail.mealsFavouriteItems[index].title,
                    imageUrl: mealsdetail.mealsFavouriteItems[index].imageUrl,
                    duration: mealsdetail.mealsFavouriteItems[index].duration,
                    affordability: mealsdetail.mealsFavouriteItems[index].affordability,
                    complexity: mealsdetail.mealsFavouriteItems[index].complexity,
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
