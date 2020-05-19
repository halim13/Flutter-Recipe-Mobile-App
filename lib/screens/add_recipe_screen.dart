import 'package:flutter/material.dart';

class AddRecipeScreen extends StatefulWidget {
  static const routeName = '/add-recipe';
  @override
  _AddRecipeState createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipeScreen> {
  int indexIngredients = 1; 

  void incrementIngredients() {
    setState(() {
      indexIngredients++;
    });
  }
  void decrementIngredients() {
    setState(() {
      indexIngredients--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Recipe'),
      ),
      body: ListView(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            height: 150,
            width: 300,
            child: textFormIngredients()
          ),
          RaisedButton(
            child: Text('Test'),
            onPressed: incrementIngredients
          )
        ]
      ),
    );
  }

  Widget textFormIngredients() {
    return Column(
      children: [
        for(var i = 0; i < indexIngredients; i++) 
          TextFormField()
      ]
    );
   }
}