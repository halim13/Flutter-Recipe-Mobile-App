import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/main.drawer.dart';
import '../../providers/auth/auth.dart';
import '../../providers/custom/bottom_navy_bar.dart';
import '../../providers/user/user.dart';
import '../profile/profile.dart';
import '../profile/edit.dart';
import '../favorite/favorites.dart';
import '../recipe/categories.dart';

class TabsScreen extends StatefulWidget {

  @override
  TabsScreenState createState() => TabsScreenState();
}

class TabsScreenState extends State<TabsScreen> {
  List<Map<String, Object>> pages;
  int selectedPageIndex = 0;

  @override
  void initState() {
    pages = [
      {
        'page': CategoriesScreen(),
        'title': 'Categories',
      },
      {
        'page': FavoritesScreen(),
        'title': 'Favorites',
      },
      {
        'page': ProfileScreen(),
        'title': 'Profil',
      },
    ];
    super.initState();
  }

  void selectPage(int index) {
    setState(() {
      selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pages[selectedPageIndex]['title']),
        actions: [
          if(selectedPageIndex == 2)
          Consumer<Auth>(
            builder: (context, authProvider, child) => authProvider.isAuth ? IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.blue.shade700,
              ), 
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return EditProfileScreen();
                  })
                );
              },
            ) : FutureBuilder(
              future: authProvider.tryAutoLogin(),
              builder: (ctx, snapshot) => Container()
            )
          )
        ],
      ),
      body: pages[selectedPageIndex]['page'],
      drawer: onlyCategoriesDrawer(selectedPageIndex),
      bottomNavigationBar: BottomNavyBar( 
        selectedIndex: selectedPageIndex,
        showElevation: false, 
        onItemSelected: (index) => setState(() {
          selectedPageIndex = index;
        }),
        items: [
          BottomNavyBarItem(
          icon: Icon(Icons.fastfood),
          title: Text('Categories'),
          activeColor: Colors.red.shade700,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.star),
            title: Text('Favorites'),
            activeColor: Colors.yellow.shade700
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.account_circle),
            title: Text('Profil'),
            activeColor: Colors.blue.shade700,
          ),
        ],
      ),
    );
  }

  Widget onlyCategoriesDrawer(int index) {
    if(index == 0) {
      return MainDrawer();
    }
    return null;
  }
}


