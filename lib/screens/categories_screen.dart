import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/color_convert.dart';
import '../providers/categories.dart';
import './category_meals_screen.dart';

class CategoriesScreen extends StatelessWidget {

  void selectCategory(BuildContext context, String id, String title) {
    Navigator.of(context).pushNamed(
      CategoryMealsScreen.routeName,
      arguments: {
        'id': id,
        'title': title,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<Categories>(context, listen: false).getCategories(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if(snapshot.hasError) {
          return Center(
            child: Text('Oops! Something went wrong! Please Try Again.'),
          );
        }
        return Consumer<Categories>(
          child: Center(
            child: const Text('You have no categories yet, start adding some!'),
          ),
          builder: (context, value, ch) => 
          value.items.length <= 0
          ? ch
          : RefreshIndicator(
              onRefresh: () => value.refreshProducts(),
              child: GridView.builder(
              itemCount: value.items.length,
              padding: const EdgeInsets.all(25),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ), 
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () => selectCategory(context, value.items[index].id, value.items[index].title),
                  splashColor: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      value.items[index].title,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          hexToColor(value.items[index].color).withOpacity(0.7),
                          hexToColor(value.items[index].color),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                );
              }
            ),
          )
        );
 
          
      }
    );
  }
}
