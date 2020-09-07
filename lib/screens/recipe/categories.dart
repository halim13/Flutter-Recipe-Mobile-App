import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/category/categories.dart';
import '../../widgets/category.grid.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<Categories>(context, listen: false).getCategories(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if(snapshot.hasError) {
          return Center(
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
          );
        }
        return Consumer<Categories>(
          child: Center(
            child: Text('There is no Categories yet')
          ),
          builder: (BuildContext context, Categories categoryProvider, Widget child) => 
          categoryProvider.getCategoriesItems.length <= 0
          ? child
          : RefreshIndicator(
            onRefresh: () => categoryProvider.refreshProducts(),
            child: CategoryGrid(
              getCategoriesItems: categoryProvider.getCategoriesItems,
            )
          )
        );
      }
    );
  }
}
