import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/connection.dart';
import '../providers/recipe.dart';
import 'meal_detail_screen.dart';

class EditRecipeScreen extends StatefulWidget {
  static const routeName = '/edit-recipe-screen';
  @override
  _EditRecipeScreenState createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  File _file;
  Timer timer;

  void save(context) async {
    final recipe = Provider.of<Recipe>(context, listen: false);
    recipe.formTitleKey.currentState.save();
    recipe.formIngredientsKey.currentState.save();
    recipe.formStepsKey.currentState.save();
    for (int i = 0; i < recipe.ingredients.length; i++) {
      TextEditingController controller = recipe.controllerIngredients[i]["item"];
      recipe.initialIngredients.add({
        "id": recipe.ingredients[i]["id"],
        "item": controller.text
      });
    }
    for (int i = 0; i < recipe.steps.length; i++) {
      TextEditingController controller = recipe.controllerSteps[i]["item"];
      recipe.initialSteps.add({
        "id": recipe.steps[i]["id"],
        "item": controller.text
      });
    }
    final seenRemoveIngredients = Set();
    final seenRemoveSteps = Set();
    final uniqueRemoveIngredients = recipe.valueIngredientsRemove.where((item) => seenRemoveIngredients.add(item["id"])).toList();
    final uniqueRemoveSteps = recipe.valueStepsRemove.where((item) => seenRemoveSteps.add(item["id"])).toList();
    final removeIngredients = jsonEncode(uniqueRemoveIngredients);
    final removeSteps = jsonEncode(uniqueRemoveSteps);
    final ingredients = jsonEncode(recipe.initialIngredients);
    final steps = jsonEncode(recipe.initialSteps);
    final mealId = ModalRoute.of(context).settings.arguments;
    try {
      if(recipe.titleController.text == "") {
        recipe.titleFocusNode.requestFocus();
        throw new Exception('Hari ini mau masak apa ?');
      }
      for (int i = 0; i < recipe.ingredients.length; i++) {
        TextEditingController controller = recipe.controllerIngredients[i]["item"];
        if(controller.text == "") {
          FocusNode node = recipe.focusIngredientsNode[i]["item"];
          node.requestFocus();
          throw new Exception('Mau makan apa tanpa ada bahan ?');
        }
      }
      for (int i = 0; i < recipe.steps.length; i++) {
        TextEditingController controller = recipe.controllerSteps[i]["item"];
        if(controller.text == "") {
          FocusNode node = recipe.focusStepsNode[i]["item"];
          node.requestFocus();
          throw new Exception('Bagaimana cara memasaknya ?');
        }
      }
      await Provider.of<Recipe>(context, listen: false).update(recipe.titleController.text, mealId, _file, ingredients, steps, removeIngredients, removeSteps, '054ba002-0122-496b-937e-32d05acef05c');
      final snackbar = SnackBar(
        content: Text('Berhasil mengubah data.'),
        action: SnackBarAction(
          label: 'Tutup',
          onPressed: () {
            Scaffold.of(context).hideCurrentSnackBar();
          }
        ),
      );
      Scaffold.of(context).showSnackBar(snackbar);
      timer = Timer(const Duration(seconds: 3), () {
        Navigator.of(context).pushReplacementNamed( 
          MealDetailScreen.routeName, 
          arguments: mealId
        );
      });
    } on Exception catch(error) {
      final errorSplit = error.toString();
      final errorText = errorSplit.split(":");
      final snackbar = SnackBar(
        content: Text(errorText[1]),
        action: SnackBarAction(
          label: 'Tutup',
          onPressed: () {
            Scaffold.of(context).hideCurrentSnackBar();
          }
        ),
      );
      Scaffold.of(context).showSnackBar(snackbar);
    } catch(error) {
      print(error); 
    }
  }

  Future<bool> onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Batal mengubah?', style: TextStyle(color: Colors.black)),
        content: Text('Data akan hilang apabila Anda keluar'),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Tidak'),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop(true);    
            },
            child: Text('Ya'),
          ),
        ],
      ),
    )) ?? false;
  }

  void dispose() {
    super.dispose();
    final recipe = Provider.of<Recipe>(context, listen: false);
    for (int i = 0; i < recipe.ingredients.length; i++) {
      TextEditingController controller = recipe.controllerIngredients[i]["item"];
      controller.dispose();
    }
     for (int i = 0; i < recipe.steps.length; i++) {
      TextEditingController controller = recipe.controllerSteps[i]["item"];
      controller.dispose();
    }
    recipe.titleFocusNode.dispose();
    timer.cancel();
  } 

  @override
  Widget build(BuildContext context) {
    final mealId = ModalRoute.of(context).settings.arguments;
    final recipe = Provider.of<Recipe>(context, listen: false);
    return FutureBuilder(
      future: Provider.of<Recipe>(context, listen: false).edit(mealId),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Edit"),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            )
          );
        }
        if(snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Edit"),
            ),
            body: Center(
              child: Text("Oops! Something went wrong! Please try again.")
            )
          );
        }
        return WillPopScope(
            onWillPop: onWillPop,
            child: Scaffold(
            appBar: AppBar(
              title: Text("Edit"),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    overflow: Overflow.visible,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 300,
                        width: double.infinity,
                        child: Image.network('$imagesRecipesUrl/${recipe.data.recipes.first.imageUrl}',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        child: IconButton(
                          color: Colors.red,
                          icon: Icon(Icons.camera_alt), 
                          onPressed: () {}
                        )
                      )
                    ]
                  ),
                  Form(
                    key: recipe.formTitleKey,
                    child: Container(
                      width: 300,
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                        focusNode: recipe.titleFocusNode,
                        controller: recipe.titleController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Nama Resep',
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ) 
                        ),
                        onSaved: (value) {
                          recipe.titleController.text = value;
                        },
                      ),
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
                    child: textFormIngredientsEdited()
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    child: Consumer<Recipe>(
                      builder: (context, recipe, child) {
                        return RaisedButton(
                          child: Text('Tambah Bahan'),
                          onPressed: () => recipe.incrementsIngredients()
                        );
                      }
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
                    child: textFormStepsEdited()
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    child: Consumer<Recipe>(
                      builder: (context, recipe, child) {
                        return RaisedButton(
                          child: Text('Tambah Prosedur'),
                          onPressed: () => recipe.incrementsSteps()
                        );
                      }
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    width: 300,
                    child: Builder(
                        builder: (context) => 
                        RaisedButton(
                        child: Text('Save'),
                        onPressed: () => save(context),  
                      ),
                    )
                  )
                ],
              )
            )
          ),
        );
      },
    );
  }

  Widget textFormIngredientsEdited() {
    return Consumer<Recipe>(
      builder: (context, recipe, child) {
        return SingleChildScrollView(
          child: Form(
          key: recipe.formIngredientsKey,
          child: Column( 
            children: List.generate(recipe.ingredients.length, (i) => Column(
              children: [
                TextFormField(
                  focusNode: recipe.focusIngredientsNode[i]["item"],
                  controller: recipe.controllerIngredients[i]["item"],
                  decoration: InputDecoration(
                    hintText: "Item $i",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ) 
                  ),
                ),
                i > 0  
                ? RaisedButton(
                  child: Text('Remove'),
                  onPressed: () => recipe.decrementIngredients(recipe.ingredients[i]["id"])
                  )
                : Container()
              ],
            ))
          ),
        )
      );
      }
    );
  }

  Widget textFormStepsEdited() {
    return Consumer<Recipe>(
      builder: (context, recipe, child) {
        return  SingleChildScrollView(
          child: Form(
            key: recipe.formStepsKey,
            child: Column( 
              children: List.generate(recipe.steps.length, (i) {
                return Column(  
                  children: [
                    TextFormField(
                      focusNode: recipe.focusStepsNode[i]["item"],
                      controller: recipe.controllerSteps[i]["item"],
                      decoration: InputDecoration(
                        hintText: "Item $i",
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ) 
                      ),
                    ),
                    i > 0 
                    ? 
                      RaisedButton(
                        child: Text('Remove'),
                        onPressed: () => recipe.decrementSteps(recipe.steps[i]["id"])
                      )
                    : Container()
                  ]
                );
              })
            ),
          )
        ); 
      }
    );
  }
}