import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/auth.dart';
import './providers/categories.dart';
import './providers/recipe.show.dart';
import './providers/recipe.detail.dart';
import './providers/user.dart';
import './providers/recipe.edit.dart';
import './providers/recipe.add.dart';
import './colors/colors.dart';
import 'screens/favorite/detail.favorite.dart';
import './screens/tabs.dart';
import 'screens/recipe/categories.dart';
import 'screens/recipe/category.dart';
import 'screens/recipe/detail.dart';
import 'screens/auth/login.dart';
import 'screens/auth/register.dart';
import 'screens/recipe/add.dart';
import 'screens/recipe/edit.dart';


void main() { 
  Provider.debugCheckInvalidValueType = null;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProvider.value(
          value: User(),
        ),
        ChangeNotifierProvider.value(
          value: Categories(),
        ),
        ChangeNotifierProvider.value(
          value: RecipeEdit(),
        ),
        ChangeNotifierProvider.value(
          value: RecipeDetail(),
        ),
        // ChangeNotifierProxyProvider<RecipeDetail, RecipeEdit>(
        //   create: (BuildContext context) =>  null,
        //   update: (BuildContext context, RecipeDetail recipeDetail, RecipeEdit recipeEdit) => RecipeEdit(recipeDetail.getRecipeFavourite())
        // ),
        ChangeNotifierProvider.value(
          value: RecipeAdd(),
        ),
        ChangeNotifierProvider.value(
          value: RecipeShow(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Recipe',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: AppBarTheme(elevation: 0.0),
          primaryColor: primaryGrey.shade50,
          accentColor: primaryRed.shade700,
          canvasColor: Color.fromARGB(255, 255, 255, 255),
          // fontFamily: 'Raleway',
          textTheme: ThemeData.light().textTheme.copyWith(
            bodyText1: TextStyle(
              color: Color.fromRGBO(20, 51, 51, 1),
            ),
            bodyText2: TextStyle(
              color: Color.fromRGBO(20, 51, 51, 1),
            ),
            headline6: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'RobotoCondensed',
              fontWeight: FontWeight.bold,
            )
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => TabsScreen(),
          LoginScreen.routeName: (context) => LoginScreen(),
          RegisterScreen.routeName: (context) => RegisterScreen(),
          CategoryMealsScreen.routeName: (context) => CategoryMealsScreen(),
          RecipeDetailScreen.routeName: (context) => RecipeDetailScreen(),
          RecipeDetailFavoriteScreen.routeName: (context) => RecipeDetailFavoriteScreen(),
          AddRecipeScreen.routeName: (context) => AddRecipeScreen(),
          EditRecipeScreen.routeName: (context) => EditRecipeScreen()
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (ctx) => CategoriesScreen(),
          );
        },
      ),
    );
  }
}
