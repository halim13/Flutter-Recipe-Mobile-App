import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/tabs_screen.dart';
import './screens/categories_screen.dart';
import './screens/category_meals_screen.dart';
import './screens/meal_detail_screen.dart';
import './providers/categories.dart';
import './providers/meals.dart';

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
          value: Categories(),
        ),
        ChangeNotifierProvider.value(
          value: Meals(),
        )
      ],
      child: MaterialApp(
        title: 'DeliMeals',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.pink,
          accentColor: Colors.amber,
          canvasColor: Color.fromRGBO(255, 254, 229, 1),
          fontFamily: 'Raleway',
          textTheme: ThemeData.light().textTheme.copyWith(
              bodyText1: TextStyle(
                color: Color.fromRGBO(20, 51, 51, 1),
              ),
              bodyText2: TextStyle(
                color: Color.fromRGBO(20, 51, 51, 1),
              ),
              headline6: TextStyle(
                fontSize: 20,
                fontFamily: 'RobotoCondensed',
                fontWeight: FontWeight.bold,
              )),
        ),
        initialRoute: '/', 
        routes: {
          '/': (ctx) => TabsScreen(),
          CategoryMealsScreen.routeName: (ctx) => CategoryMealsScreen(),
          MealDetailScreen.routeName: (ctx) => MealDetailScreen(),
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
