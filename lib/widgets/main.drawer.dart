import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../screens/add.recipe.dart';
import '../screens/login.dart';

class MainDrawer extends StatelessWidget {
  Widget buildListTile(String title, IconData icon, Function tapHandler) {
    return ListTile(
      leading: Icon(
        icon,
        size: 26,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'RobotoCondensed',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: tapHandler,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            padding: EdgeInsets.all(20),
            alignment: Alignment.centerLeft,
            color: Theme.of(context).accentColor,
            child: Text(
              'Cooking Up!',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 30,
                color: Theme.of(context).primaryColor
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Consumer<Auth>(
            builder: (context, authProvider, child) {
              if(authProvider.isAuth) {
                return buildListTile('Tulis Resep', Icons.restaurant_menu, () {
                  Navigator.of(context).pushNamed(AddRecipeScreen.routeName);
                });
              } else {
                return FutureBuilder(
                  future: authProvider.tryAutoLogin(),
                  builder: (ctx, snapshot) =>
                  Container()
                );
              }
            },
          ),
          Consumer<Auth>(
            builder: (context, auth, child) {
              if(auth.isAuth) {
                return buildListTile('Logout', Icons.account_circle, () {
                  auth.logout();
                });
              } else { 
                return FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, snapshot) =>
                  buildListTile('Login', Icons.account_circle, () {
                    Navigator.of(context).pushNamed(LoginScreen.routeName);
                  }),
                );
              }
            },
          ),
          // buildListTile('Meals', Icons.restaurant, () {
          //   Navigator.of(context).pushReplacementNamed('/');
          // }),
          // buildListTile('Filter', Icons.settings, () {
          //   Navigator.of(context).pushReplacementNamed(FiltersScreen.routeName);
          // }),
        ],
      ),
    );
  }
}
