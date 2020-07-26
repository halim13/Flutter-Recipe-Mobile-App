// import 'dart:collection'; Dipakai jika menggunakan linkedhash
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/Category.dart';
import '../providers/recipe.dart';

class AddRecipeScreen extends StatefulWidget {
  static const routeName = '/add-recipe';
  @override
  _AddRecipeState createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipeScreen> {
  bool loading = false;
  String title;
  String _file;
  final GlobalKey<FormState> formIngredientsKey = GlobalKey();
  final GlobalKey<FormState> formStepsKey = GlobalKey();
  final GlobalKey<FormState> formTitleKey = GlobalKey();
  List<CategoryData> categories = CategoryData.getCategoriesDropdown();
  List<DropdownMenuItem<CategoryData>> dropdownMenuItems = [];
  CategoryData selectedCategory;
  List<Map<String, Object>> valueIngredientsController = [];
  List<Map<String, Object>> valueStepsController = [];
  List<TextEditingController> listIngredientsController = [TextEditingController()];
  List<TextEditingController> listStepsController = [TextEditingController()];
  int startIngredients = 1; 
  int startSteps = 1;
  void incrementIngredients() {
    setState(() {
      startIngredients++;
      listIngredientsController.add(TextEditingController());
    });
  }
  void incrementSteps() {
    setState(() {
      startSteps++;
      listStepsController.add(TextEditingController());
    });
  }
  void decrementIngredients(i) {
    setState(() {
      startIngredients--;
      valueIngredientsController.removeWhere((element) => element["id"] == i);
      listIngredientsController.removeWhere((element) => element == listIngredientsController[i]);
    });
  }
  void decrementSteps(i) {
    setState(() {
      startSteps--;
      valueStepsController.removeWhere((element) => element["id"] == i);
      listStepsController.removeWhere((element) => element == listStepsController[i]);
    });
  }
  void pickImage() async {
    final imageSource = await showDialog<ImageSource>(context: context, builder: (context) =>
      AlertDialog(
        title: Text(
          "Pilih sumber gambar",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold, 
        ),
      ),
      actions: <Widget>[
        MaterialButton(
          child: Text(
            "Camera",
            style: TextStyle(color: Colors.blueAccent),
          ),
          onPressed: () => Navigator.pop(context, ImageSource.camera),
        ),
        MaterialButton(
          child: Text(
            "Gallery",
            style: TextStyle(color: Colors.blueAccent),
          ),
          onPressed: () => Navigator.pop(context, ImageSource.gallery),
        )
      ],
    ));
    if(imageSource != null) {
      PickedFile file = await ImagePicker().getImage(source: imageSource);
      if(file != null) {
        setState(() => _file = file.path);
      }
    }
  }
  void save() async {
    formIngredientsKey.currentState.save();
    formStepsKey.currentState.save();
    formTitleKey.currentState.save();
    final seenSteps = Set<int>();
    final seenIngredients = Set<int>();
    final uniqueSteps = valueStepsController.where((str) => seenSteps.add(str["id"])).toList(); // Biar ngga duplicate
    final uniqueIngredients = valueIngredientsController.where((str) => seenIngredients.add(str["id"])).toList(); // Biar ngga duplicate
    final steps = jsonEncode(uniqueSteps); // Agar bisa di parse di backend
    final ingredients = jsonEncode(uniqueIngredients); // Agar bisa di parse di backend 
   try {
      setState(() => loading = true);
      await Provider.of<Recipe>(context, listen: false).store(title, ingredients, steps, selectedCategory.uuid, _file);
      setState(() => loading = false);
    } catch(error) {
      setState(() => loading = false);
      print(error);
      throw error;
    } 
  }

  @override
  void dispose() {
    for (int i = 0; i < startIngredients; i++) {
      listIngredientsController[i].dispose();
    }
    for (int i = 0; i < startSteps; i++) {
      listStepsController[i].dispose();
    }
    super.dispose();
  }
  void initState() {
    dropdownMenuItems = buildDropdownMenuItems(categories);
    selectedCategory = dropdownMenuItems[0].value;
    super.initState();
  }
  List<DropdownMenuItem<CategoryData>> buildDropdownMenuItems(List categories) {
    List<DropdownMenuItem<CategoryData>> items = [];
      for(CategoryData category in categories) {
        items.add(
          DropdownMenuItem(
            value: category,
            child: Text(category.title),
          )
        );
      }
    return items;
  } 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Recipe'),
      ),
      body: ListView(
        children: [
          Stack(
            overflow: Overflow.visible,
            alignment: Alignment.center,
            children: [
              Container(
                height: 300,
                width: double.infinity,
                child: _file == null ? Image.asset(
                  'assets/default-thumbnail.jpg',
                  fit: BoxFit.cover,
                ) :  Image.file(File(_file))),
              Positioned(
                child: IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.camera_alt), 
                  onPressed: pickImage
                )
              )
            ]
          ),
          Form(
            key: formTitleKey,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              child: TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Title',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ) 
                ),
                onSaved: (value) {
                  setState(() => title = value);
                },
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
            width: double.infinity,
            child: textFormIngredients()
          ),
          Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            width: double.infinity,
            child: RaisedButton(
              child: Text('Add ingredients'),
              onPressed: incrementIngredients
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
            width: double.infinity,
            child: textFormSteps()
          ),
          Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            width: double.infinity,
            child: RaisedButton(
              child: Text('Add Steps'),
              onPressed: incrementSteps
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            child: DropdownButton<CategoryData>(
              value: selectedCategory,
              elevation: 16,
              underline: Container(
                height: 1,
                color: Colors.grey,
              ),
              onChanged: (CategoryData value) {
                setState(() => selectedCategory = value);
              },
              items: dropdownMenuItems,
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            width: double.infinity,
            child: RaisedButton(
              child: Text('Save'),
              onPressed: save,
            ),
          )
        ]
      ),
    );
  }

  Widget textFormIngredients() {
    int itemStart = 1;
    return SingleChildScrollView(
      child: Form(
        key: formIngredientsKey,
        child: Column( 
          children: List.generate(startIngredients, (i) {
            return Column(  
              children: [
                TextFormField(
                  controller: listIngredientsController[i],
                  decoration: InputDecoration(
                    hintText: "Item ${itemStart++}",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ) 
                  ),
                  onSaved: (value) {    
                    valueIngredientsController.add({
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
  Widget textFormSteps() {
    int itemStart = 1;
    return SingleChildScrollView(
      child: Form(
        key: formStepsKey,
        child: Column( 
          children: List.generate(startSteps, (i) {
            return Column(  
              children: [
                TextFormField(
                  controller: listStepsController[i],
                  decoration: InputDecoration(
                    hintText: "Step ${itemStart++}",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ) 
                  ),
                  onSaved: (value) {    
                    valueStepsController.add({
                      "id": i,
                      "item": value
                    }); 
                  },
                ),
                i > 0 
                ? 
                  RaisedButton(
                    child: Text('Remove'),
                    onPressed: () => decrementSteps(i)
                  )
                : Container()
              ]
            );
          })
        ),
      )
    );
  }


}
