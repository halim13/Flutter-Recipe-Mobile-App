// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../widgets/category_item.dart';
// import '../providers/categories.dart';

// class CategoriesGrid extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {  
//     final categoriesData = Provider.of<Categories>(context, listen: false);
//     final categories = categoriesData.categories;
//     return GridView.builder(
//       padding: const EdgeInsets.all(25),
//       itemCount: categories.length,
//       itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
//         value: categories[i],
//         child: CategoryItem(),
//       ),
//       gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
//         maxCrossAxisExtent: 200,
//         childAspectRatio: 3 / 2,
//         crossAxisSpacing: 20,
//         mainAxisSpacing: 20,
//       )
//     );
//   }
// }