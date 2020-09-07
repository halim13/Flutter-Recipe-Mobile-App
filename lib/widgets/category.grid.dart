import 'package:flutter/material.dart';

import './category.item.dart';
import '../models/Category.dart';


class CategoryGrid extends StatelessWidget {
  final List<CategoryData> getCategoriesItems;

  CategoryGrid({
    this.getCategoriesItems
  });
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: getCategoriesItems.length,
      padding: EdgeInsets.all(25.0),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200.0,
        childAspectRatio: 3.0 / 2.0,
        crossAxisSpacing: 20.0,
        mainAxisSpacing: 20.0,
      ), 
      itemBuilder: (context, i) {
        return CategoryItem(
          uuid: getCategoriesItems[i].uuid,
          title: getCategoriesItems[i].title,
          cover: getCategoriesItems[i].cover,
        );
      }
    );
  }
}
