import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info/package_info.dart';

import '../providers/auth/auth.dart';
import '../screens/auth/login.dart';

class MainDrawer extends StatefulWidget {
  
  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  
   PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }
  Widget buildListTile(String title, IconData icon, Function tapHandler) {
    return ListTile(
      leading: Icon(
        icon,
        size: 26.0,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'RobotoCondensed',
          fontSize: 24.0,
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
            height: 120.0,
            width: double.infinity,
            padding: EdgeInsets.all(20.0),
            alignment: Alignment.bottomRight,
            color: Colors.blue.shade700,
            child: Text(
              _packageInfo.version,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.bold
              ),
            ),
            // color: Theme.of(context).accentColor,
            // child: Text(
            //   'Cooking Up!',
            //   style: TextStyle(
            //     fontWeight: FontWeight.w900,
            //     fontSize: 30,
            //     color: Theme.of(context).primaryColor
            //   ),
            // ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Consumer<Auth>(
            builder: (context, authProvider, child) {
              if(authProvider.isAuth) {
                return buildListTile('Add Recipe', Icons.restaurant_menu, () {
                  Navigator.of(context).pushNamed('/add-recipe');
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
            builder: (context, authProvider, child) {
              if(authProvider.isAuth) {
                return buildListTile('My Recipes', Icons.receipt, () {
                  Navigator.of(context).pushNamed('/my-recipe');
                });
              } else {
                return FutureBuilder(
                  future: authProvider.tryAutoLogin(),
                  builder: (ctx, snapshot) => Container()
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
