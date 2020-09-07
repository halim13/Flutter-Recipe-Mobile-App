import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './constants/routes.dart';
import './colors/colors.dart';

import './providers/auth/auth.dart';
import './providers/category/categories.dart';
import './providers/user/user.dart';
import './providers/recipe/my.recipe.dart';
import './providers/recipe/my.draft.dart';
import './providers/recipe/show.dart';
import './providers/recipe/detail.dart';
import './providers/recipe/edit.dart';
import './providers/recipe/add.dart';

import './screens/tabs/tabs.dart';

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
          value: MyRecipe(),
        ),
        ChangeNotifierProvider.value(
          value: MyDraft(),
        ),
        ChangeNotifierProvider.value(
          value: RecipeEdit(),
        ),
        ChangeNotifierProvider.value(
          value: RecipeDetail(),
        ),
        ChangeNotifierProvider.value(
          value: RecipeAdd(),
        ),
        ChangeNotifierProvider.value(
          value: RecipeShow(),
        ),
      ],
      child: MaterialApp(
        title: 'Chumbuckets Recipes',
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
              fontSize: 20.0,
              fontFamily: 'RobotoCondensed',
              fontWeight: FontWeight.bold,
            )
          ),
        ),
        initialRoute: '/',
        routes: appRoutes,
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (BuildContext context) => TabsScreen(),
          );
        },
      ),
    );
  }
}
