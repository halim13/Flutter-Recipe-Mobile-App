import 'package:flutter/material.dart';
import '../providers/custom/bottom_navy_bar.dart';
import '../widgets/main.drawer.dart';
import 'profile.dart';
import 'favorites.recipe.dart';
import 'categories.dart';

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
        'title': 'Profile',
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
      ),
      body: pages[selectedPageIndex]['page'],
      drawer: MainDrawer(),
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
            title: Text('Favourites'),
            activeColor: Colors.yellow.shade700
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.account_circle),
            title: Text('Profile'),
            activeColor: Colors.blue.shade700,
          ),
        ],
      ),
    );
  }
}


