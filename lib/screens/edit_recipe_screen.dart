import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/connection.dart';
import '../providers/recipe.dart';

class EditRecipeScreen extends StatefulWidget {
  static const routeName = '/edit-recipe-screen';
  @override
  _EditRecipeScreenState createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  File _file;

  void save() async {
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
      await Provider.of<Recipe>(context, listen: false).update(recipe.titleController.text, mealId, _file, ingredients, steps, removeIngredients, removeSteps, '054ba002-0122-496b-937e-32d05acef05c');
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
  } 

  @override
  Widget build(BuildContext context) {
    final mealId = ModalRoute.of(context).settings.arguments;
    final provider = Provider.of<Recipe>(context, listen: false);
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
        return Scaffold(
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
                      child: Image.network('$imagesRecipesUrl/${provider.data.recipes.first.imageUrl}',
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
                  key: provider.formTitleKey,
                  child: Container(
                    width: 300,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    child: TextFormField(
                      controller: provider.titleController,
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
                  width: 300,
                  child: textFormIngredientsEdited()
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  width: 300,
                  child: Consumer<Recipe>(
                    builder: (context, recipe, child) {
                      return RaisedButton(
                        child: Text('Add ingredients'),
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
                  width: 300,
                  child: textFormStepsEdited()
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  width: 300,
                  child: Consumer<Recipe>(
                    builder: (context, recipe, child) {
                      return RaisedButton(
                        child: Text('Add Steps'),
                        onPressed: () => recipe.incrementsSteps()
                      );
                    }
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  width: 300,
                  child: RaisedButton(
                    child: Text('Save'),
                    onPressed: save,  
                  )
                )
              ],
            )
          )
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
            // children: recipe.getIngredients.asMap().map((i, item) => MapEntry(i, 
            // Column(
            //   children: [
            //     TextFormField(
            //       // controller: recipe.listIngredientsController[i]["item"],
            //       controller: recipe.listIngredientsControllerCopy[i],
            //       decoration: InputDecoration(
            //         hintText: "Item $i",
            //         enabledBorder: UnderlineInputBorder(
            //           borderSide: BorderSide(color: Colors.grey),
            //         ),
            //         focusedBorder: UnderlineInputBorder(
            //           borderSide: BorderSide(color: Colors.grey),
            //         ) 
            //       ),
            //       onSaved: (value) {               
            //         // recipe.valueIngredients.add({
            //         //   "id": i,
            //         //   "body": item.body 
            //         // });
            //       }
            //     ),
            //     i > 0  
            //     ? RaisedButton(
            //       child: Text('Remove'),
            //       onPressed: () => recipe.decrementIngredients(item.id, i)
            //       )
            //     : Container()
            //   ]
            // ))).values.toList()
             
              // return Column(  
              //   children: [
              //     TextFormField(
              //       initialValue: item.body,
              //       decoration: InputDecoration(
              //         hintText: "Item",
              //         enabledBorder: UnderlineInputBorder(
              //           borderSide: BorderSide(color: Colors.grey),
              //         ),
              //         focusedBorder: UnderlineInputBorder(
              //           borderSide: BorderSide(color: Colors.grey),
              //         ) 
              //       ),
              //       onSaved: (value) {               
                     
              //       },
              //     ),
              //     RaisedButton(
              //       child: Text('Remove'),
              //       onPressed: () => recipe.decrementIngredients(item.id)
              //     )
              //   ]
              // );
          //  }).toList()
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