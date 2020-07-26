import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/categories.dart';
import 'category.recipe.dart';

class CategoriesScreen extends StatelessWidget {
  void selectCategory(BuildContext context, String uuid, String title) {
    Navigator.of(context).pushNamed(
      CategoryMealsScreen.routeName,
      arguments: {
        'uuid': uuid,
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
              padding: EdgeInsets.all(25.0),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200.0,
                childAspectRatio: 3.0 / 2.0,
                crossAxisSpacing: 20.0,
                mainAxisSpacing: 20.0,
              ), 
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () => selectCategory(context, value.items[index].uuid, value.items[index].title),
                  splashColor: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(15.0),
                  child: Container(
                    padding: EdgeInsets.all(15.0),
                    child: Container(
                      padding: EdgeInsets.all(5.0),
                      child: Text(
                        value.items[index].title,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    decoration: BoxDecoration(
                      // gradient: LinearGradient(
                      //   colors: [
                      //     hexToColor(value.items[index].color).withOpacity(0.7),
                      //     hexToColor(value.items[index].color),
                      //   ],
                      //   begin: Alignment.topLeft,
                      //   end: Alignment.bottomRight,
                      // ),
                      image: DecorationImage(
                        image: value.items[index].cover != "" ? NetworkImage(value.items[index].cover) : AssetImage('assets/default-thumbnail.jpg'),
                        fit: BoxFit.cover
                      ),
                      borderRadius: BorderRadius.circular(15.0),
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
