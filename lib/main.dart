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
import './screens/tabs.dart';
import './screens/categories.dart';
import './screens/category.recipe.dart';
import './screens/recipe.detail.dart';
import './screens/login.dart';
import './screens/register.dart';
import './screens/add.recipe.dart';
import './screens/edit.recipe.dart';


void main() => runApp(MyApp());

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
          value: RecipeAdd(),
        ),
        ChangeNotifierProvider.value(
          value: RecipeShow(),
        ),
        ChangeNotifierProvider.value(
          value: RecipeDetail(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Recipe',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: AppBarTheme(elevation: 0.0),
          primaryColor: primaryGrey.shade50,
          accentColor: primaryRed.shade700,
          canvasColor: const Color.fromARGB(255, 255, 255, 255),
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
          '/': (ctx) => TabsScreen(),
          LoginScreen.routeName: (ctx) => LoginScreen(),
          RegisterScreen.routeName: (ctx) => RegisterScreen(),
          CategoryMealsScreen.routeName: (ctx) => CategoryMealsScreen(),
          RecipeDetailScreen.routeName: (ctx) => RecipeDetailScreen(),
          AddRecipeScreen.routeName: (ctx) => AddRecipeScreen(),
          EditRecipeScreen.routeName: (ctx) => EditRecipeScreen()
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
