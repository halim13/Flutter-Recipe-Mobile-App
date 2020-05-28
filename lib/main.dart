import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/auth.dart';
import './providers/categories.dart';
import './providers/meals_show.dart';
import './providers/meals_detail.dart';
import './providers/user.dart';
import './providers/recipe.dart';
import './screens/tabs_screen.dart';
import './screens/categories_screen.dart';
import './screens/category_meals_screen.dart';
import './screens/meal_detail_screen.dart';
import './screens/login_screen.dart';
import './screens/register_screen.dart';
import './screens/add_recipe_screen.dart';
import './screens/edit_recipe_screen.dart';
import './colors/colors.dart';

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
          value: Recipe(),
        ),
        ChangeNotifierProvider.value(
          value: Categories(),
        ),
        ChangeNotifierProvider.value(
          value: MealsShow(),
        ),
        ChangeNotifierProvider.value(
          value: MealsDetail(),
        ),
      ],
      child: MaterialApp(
        title: 'ResepMama',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: AppBarTheme(elevation: 0.0),
          primaryColor: primaryGrey.shade50,
          accentColor: primaryRed.shade700,
          canvasColor: const Color.fromARGB(255, 255, 255, 255),
          fontFamily: 'Raleway',
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
          MealDetailScreen.routeName: (ctx) => MealDetailScreen(),
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
