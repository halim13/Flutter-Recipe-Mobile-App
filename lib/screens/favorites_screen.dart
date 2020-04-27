import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/meals_detail.dart';
import 'package:provider/provider.dart';
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
          child: Container(
            child: RefreshIndicator(
              onRefresh: () => provider.refreshMealsFavourite(),
              child: Center(
                child: Text('You have no favorites yet - start adding some!'),
              ),
            )
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
                    id: mealsdetail.mealsFavouriteItems[index].id,
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
