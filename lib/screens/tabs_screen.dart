import 'package:flutter/material.dart';
import '../widgets/main_drawer.dart';
import '../screens/favorites_screen.dart';
import './categories_screen.dart';

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
        'title': 'Category',
      },
      {
        'page': FavoritesScreen(),
        'title': 'Favorites',
      },
    ];
    super.initState();
  }

  void _selectPage(int index) {
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
      drawer: MainDrawer(),
      body: pages[selectedPageIndex]['page'],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        backgroundColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.white,
        selectedItemColor: Theme.of(context).accentColor,
        currentIndex: selectedPageIndex,
        // type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.category),
            title: Text('Categories'),
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.star),
            title: Text('Favorites'),
          ),
        ],
      ),
    );
  }
}
