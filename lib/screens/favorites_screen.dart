import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meals.dart';
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
    return FutureBuilder(
      future: Provider.of<Meals>(context, listen: false).getMealsFavourite(),
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
        return Consumer<Meals>(
          child: Center(
            child: Text('You have no favorites yet - start adding some!'),
          ),
          builder: (context, value, ch) {
            if(value.mealsFavouriteItems.length <= 0) {
              return ch;
            }
            return RefreshIndicator(
                onRefresh: () => value.refreshFavourites(),
                child: ListView.builder(
                itemCount: value.mealsFavouriteItems.length,
                itemBuilder: (context, index) {
                  return MealItem(
                    id: value.mealsFavouriteItems[index].id,
                    title: value.mealsFavouriteItems[index].title,
                    imageUrl: value.mealsFavouriteItems[index].imageUrl,
                    duration: value.mealsFavouriteItems[index].duration,
                    affordability: value.mealsFavouriteItems[index].affordability,
                    complexity: value.mealsFavouriteItems[index].complexity,
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
