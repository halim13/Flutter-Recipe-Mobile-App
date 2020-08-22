import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/categories.dart';
import 'category.recipe.dart';

class CategoriesScreen extends StatelessWidget {
  static const routeName = '/categories';
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
            child: Text('Kamu belum memiliki kategori.'),
          ),
          builder: (context, categoryProvider, child) => 
          categoryProvider.items.length <= 0
          ? child
          : RefreshIndicator(
              onRefresh: () => categoryProvider.refreshProducts(),
              child: GridView.builder(
                itemCount: categoryProvider.items.length,
                padding: EdgeInsets.all(25.0),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200.0,
                  childAspectRatio: 3.0 / 2.0,
                  crossAxisSpacing: 20.0,
                  mainAxisSpacing: 20.0,
                ), 
              itemBuilder: (context, i) {
                return InkWell(
                  onTap: () => selectCategory(context, categoryProvider.items[i].uuid, categoryProvider.items[i].title),
                  splashColor: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(15.0),
                  child: Container(
                    child: CachedNetworkImage(
                      imageUrl: '${categoryProvider.items[i].cover}',
                      imageBuilder: (context, imageProvider) => Container(
                      child: Text(
                        categoryProvider.items[i].title,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      padding: EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider, 
                            fit: BoxFit.cover
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      placeholder: (context, url) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/default-thumbnail.jpg'), 
                            fit: BoxFit.cover
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/default-thumbnail.jpg'), 
                            fit: BoxFit.cover
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      fadeOutDuration: Duration(seconds: 1),
                      fadeInDuration: Duration(seconds: 1),
                    ),
                  )
                  // child: Container(
                  //   padding: EdgeInsets.all(15.0),
                  //   child: Text(
                  //     categoryProvider.items[i].title,
                  //     style: Theme.of(context).textTheme.headline6,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     image: DecorationImage(
                  //       image: categoryProvider.items[i].cover != null ? categoryProvider.items[i].cover != "" ? NetworkImage(categoryProvider.items[i].cover) : AssetImage('assets/default-thumbnail.jpg') : AssetImage('assets/default-thumbnail.jpg'),
                  //       fit: BoxFit.cover
                  //     ),
                  //     borderRadius: BorderRadius.circular(15.0),
                  //   ),
                  // ),
                );
              }
            ),
          )
        );
      }
    );
  }
}
