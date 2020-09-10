import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/category/categories.dart';
import '../../widgets/category.grid.dart';
import '../../helpers/connectivity.service.dart';
import '../../helpers/show.error.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  
  refresh() {
    setState(() {});    
  }
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
          return ShowError(
            notifyParent: refresh,
          );
        }
        return Consumer<Categories>(
          child: Center(
            child: Text('There is no Categories yet',
              style: TextStyle(
                fontSize: 16.0
              ),
            )
          ),
          builder: (BuildContext context, Categories categoryProvider, Widget child) => 
          categoryProvider.getCategoriesItems.length <= 0
          ? child
          : RefreshIndicator(
            onRefresh: () => categoryProvider.refreshProducts(),
            child: ConnectivityService(
              widget: CategoryGrid(
                getCategoriesItems: categoryProvider.getCategoriesItems,
              ),
              refresh: refresh,
            )
          )
        );
      }
    );
  }
}
