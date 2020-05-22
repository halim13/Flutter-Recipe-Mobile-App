// import 'dart:collection'; Dipakai jika menggunakan linkedhash
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe.dart';

class AddRecipeScreen extends StatefulWidget {
  static const routeName = '/add-recipe';
  @override
  _AddRecipeState createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipeScreen> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final GlobalKey<FormState> titleFormKey = GlobalKey();
  List<Map<String, Object>> valueController = [];
  Map<int, Object> valueObject = {};
  List<TextEditingController> listController = [TextEditingController()];
  int startIngredients = 1; 
  void incrementIngredients() {
    setState(() {
      startIngredients++;
      listController.add(TextEditingController());
    });
  }
  void decrementIngredients(i) {
    setState(() {
      startIngredients--;
      valueController.removeWhere((element) => element["id"] == i);
      listController.remove(TextEditingController());
    });
  }
  void save() async {
    formKey.currentState.save();
    final seen = Set<int>();
    final unique = valueController.where((str) => seen.add(str["id"])).toList();
    print(unique);
  }

  @override
  void dispose() {
    for (var i = 0; i < startIngredients; i++) {
      listController[i].dispose();
    }
    super.dispose();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Recipe'),
      ),
      body: ListView(
        children: [
          Container(
            height: 300,
            width: double.infinity,
            child: Image.asset(
              'assets/default-thumbnail.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Form(
            key: titleFormKey,
            child: Container(
              width: 300,
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              child: TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Title'
                ),
              )
            ),
          ),
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
            child: Text('Add ingredients'),
            onPressed: incrementIngredients
          ),
          RaisedButton(
            child: Text('Save'),
            onPressed: save,
          )
        ]
      ),
    );
  }

  Widget textFormIngredients() {
    int itemStart = 1;
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column( 
          children: List.generate(startIngredients, (i) {
            return Column(  
              children: [
                TextFormField(
                  controller: listController[i],
                  decoration: InputDecoration(
                    hintText: "Item ${itemStart++}"
                  ),
                  onSaved: (value) {    
                    valueController.add({
                      "id": i,
                      "item": value
                    }); 
                  },
                ),
                i > 0 
                ? 
                  RaisedButton(
                    child: Text('Remove'),
                    onPressed: () => decrementIngredients(i)
                  )
                : Container()
              ]
            );
          })
        ),
      )
    );
  }

  // Widget removeButton() {
  //   return shadowIndex > 0 ? RaisedButton(
  //     child: Text('Remove'),
  //     onPressed: () {
  //       formKey.currentState.save(); 
  //       setState(() {
  //         startIngredients--;
  //         shadowIndex--;
  //         listController.remove(TextEditingController());
  //         valueController.removeWhere((element) => element["id"] == shadowIndex);
  //       });
  //     }
  //   ) : Container();
  // }
}
