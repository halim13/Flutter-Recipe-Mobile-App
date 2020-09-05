import 'package:flutter_complete_guide/screens/favorite/detail.favorite.dart';

import '../screens/tabs/tabs.dart';
import '../screens/auth/login.dart';
import '../screens/auth/register.dart';
import '../screens/recipe/my.recipe.dart';
import '../screens/recipe/my.draft.dart';
import '../screens/recipe/add.dart';
import '../screens/recipe/edit.dart';
import '../screens/recipe/show.dart';
import '../screens/recipe/detail.dart';

final appRoutes = {
  "/": (context) => TabsScreen(),
  "/login": (context) => LoginScreen(),
  "/register": (context) => RegisterScreen(),
  "/my-recipe": (context) => MyRecipeScreen(),
  "/my-draft": (context) => MyDraftScreen(),
  "/add-recipe": (context) => AddRecipeScreen(),
  "/edit-recipe": (context) => EditRecipeScreen(),
  "/show-recipe": (context) => ShowRecipeScreen(),
  "/detail-recipe": (context) => RecipeDetailScreen(),
  "/detail-recipe-favorite": (context) => RecipeDetailFavoriteScreen()
};