import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/connection.dart';
import '../providers/recipe.dart';
import 'meal_detail_screen.dart';

class EditRecipeScreen extends StatefulWidget {
  static const routeName = '/edit-recipe-screen';
  @override
  _EditRecipeScreenState createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  Timer timer;

  void pickImage(int i, int z, String id) async {
    final imageSource = await showDialog<ImageSource>(context: context, builder: (context) => 
      AlertDialog(
        title: Text("Pilih sumber gambar",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold, 
        ),
      ),
      actions: [
        MaterialButton(
          child: Text(
            "Camera",
            style: TextStyle(
              color: Colors.blueAccent
            )
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
      final recipe = Provider.of<Recipe>(context, listen: false);
      recipe.pickedFile = await ImagePicker().getImage(source: imageSource);
      recipe.stepsImage(i, z);
    }
  }

  void save(context) async {
    final recipe = Provider.of<Recipe>(context, listen: false);
    recipe.formTitleKey.currentState.save();
    recipe.formIngredientsKey.currentState.save();
    recipe.formStepsKey.currentState.save();
    for (int i = 0; i < recipe.ingredients.length; i++) {
      TextEditingController controller = recipe.controllerIngredients[i]["item"];
      recipe.initialIngredients.add({
        "id": recipe.ingredients[i].id,
        "item": controller.text
      });
    }
    for (int i = 0; i < recipe.steps.length; i++) {
      TextEditingController controller = recipe.controllerSteps[i]["item"];
      for (int z = 0; z < recipe.steps[i].images.length; z++) {
        recipe.initialSteps.add({
          "id": recipe.steps[i].id,
          "item": controller.text
        });
      }
    }
    final seenRemoveIngredients = Set();
    final seenRemoveSteps = Set();
    final seenSteps = Set();
    final uniqueRemoveIngredients = recipe.valueIngredientsRemove.where((item) => seenRemoveIngredients.add(item["id"])).toList();
    final uniqueRemoveSteps = recipe.valueStepsRemove.where((item) => seenRemoveSteps.add(item["id"])).toList();
    final uniqueSteps = recipe.initialSteps.where((item) => seenSteps.add(item["id"])).toList();
    final removeIngredients = jsonEncode(uniqueRemoveIngredients);
    final removeSteps = jsonEncode(uniqueRemoveSteps);
    final ingredients = jsonEncode(recipe.initialIngredients);
    final steps = jsonEncode(uniqueSteps);
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
      await Provider.of<Recipe>(context, listen: false).update(recipe.titleController.text, mealId, ingredients, steps, removeIngredients, removeSteps, '054ba002-0122-496b-937e-32d05acef05c');
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
      // timer = Timer(const Duration(seconds: 3), () {
      //   Navigator.of(context).pushReplacementNamed( 
      //     MealDetailScreen.routeName, 
      //     arguments: mealId
      //   );
      // });
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
                        height: 300.0,
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
                      width: 300.0,
                      margin: EdgeInsets.all(10.0),
                      padding: EdgeInsets.all(10.0),
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
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    margin: EdgeInsets.all(10.0),
                    padding: EdgeInsets.all(10.0),
                    height: 150.0,
                    width: double.infinity,
                    child: textFormIngredientsEdited()
                  ),
                  Container(
                    margin: EdgeInsets.all(10.0),
                    padding: EdgeInsets.all(10.0),
                    width: double.infinity,
                    child: Consumer<Recipe>(
                      builder: (context, recipe, child) {
                        return RaisedButton(
                          elevation: 0.0,
                          color: Colors.purpleAccent,
                          child: Text(
                            'Bahan +',
                            style: TextStyle(
                              color: Colors.white
                            ),  
                          ),
                          onPressed: () => recipe.incrementsIngredients()
                        );
                      }
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    margin: EdgeInsets.all(10.0),
                    padding: EdgeInsets.all(10.0),
                    height: 150.0,
                    width: double.infinity,
                    child: textFormStepsEdited()
                  ),
                  Container(
                    margin: EdgeInsets.all(10.0),
                    padding: EdgeInsets.all(10.0),
                    width: double.infinity,
                    child: Consumer<Recipe>(
                      builder: (context, recipe, child) {
                        return RaisedButton(
                          elevation: 0.0,
                          color: Colors.purpleAccent,
                          child: Text('Langkah +', 
                            style: TextStyle(
                              color: Colors.white
                            ),  
                          ),
                          onPressed: () => recipe.incrementsSteps()
                        );
                      }
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10.0),
                    padding: EdgeInsets.all(10.0),
                    width: 300.0,
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
                  style: TextStyle(
                    fontSize: 15.0
                  ),
                  focusNode: recipe.focusIngredientsNode[i]["item"],
                  controller: recipe.controllerIngredients[i]["item"],
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(top: 14.0),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: i > 0 ? Colors.grey : Colors.white,
                      ),
                      onPressed: () { 
                        if(i > 0) {
                          recipe.decrementIngredients(recipe.ingredients[i].id);
                        } else {
                          return null;
                        }
                      },
                    ),
                    prefixIcon: IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.grey,
                      ),
                      onPressed: null,
                    ),
                    hintStyle: TextStyle(
                      fontSize: 15.0
                    ),
                    hintText: "Mis: 1 kg sapi",
                    // enabledBorder: UnderlineInputBorder(
                    //   borderSide: BorderSide(color: Colors.grey),
                    // ),
                    // focusedBorder: UnderlineInputBorder(
                    //   borderSide: BorderSide(color: Colors.grey),
                    // ) 
                  ),
                ),
                // i > 0  
                // ? RaisedButton(
                //   child: Text('Remove'),
                //   onPressed: () => recipe.decrementIngredients(recipe.ingredients[i]["id"])
                //   )
                // : Container()
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
        return SingleChildScrollView(
          child: Form(
            key: recipe.formStepsKey,
            child: Column( 
              children: List.generate(recipe.steps.length, (i) {
                return Column(  
                  children: [
                    TextFormField(
                      style: TextStyle(
                        fontSize: 15.0
                      ),
                      focusNode: recipe.focusStepsNode[i]["item"],
                      controller: recipe.controllerSteps[i]["item"],
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(top: 14.0),
                        hintStyle: TextStyle(
                          fontSize: 15.0
                        ),
                        hintText: "Bagaimana langkah membuatnya?",
                        prefixIcon: IconButton(
                          icon: Container(
                            width: 35.0,
                            height: 35.0,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.black
                            ),
                            child: Text(
                              '${i + 1}', 
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                              )
                            )
                          ),
                          onPressed: null,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: i > 0 ? Colors.grey : Colors.white,
                          ),
                          onPressed: () {
                            if(i > 0) {
                              recipe.decrementSteps(recipe.steps[i].id);
                            } else {
                              return null;
                            }
                          },
                        )
                        // enabledBorder: UnderlineInputBorder(
                        //   borderSide: BorderSide(color: Colors.grey),
                        // ),
                        // focusedBorder: UnderlineInputBorder(
                        //   borderSide: BorderSide(color: Colors.grey),
                        // ) 
                      ),
                    ),
                    Row(
                      children: List.generate(recipe.steps[0].images.length, (z) =>
                        Container(
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: 80.0,
                                    height: 80.0,
                                    margin: EdgeInsets.all(10.0),
                                    child: InkWell( 
                                      child: recipe.steps[i].images[z].body,                                                   
                                      onTap: () => pickImage(i, z, recipe.steps[i].images[z].id)
                                    )
                                  ),
                                ],
                              )
                            ],  
                          )
                        ) 
                      )
                    )
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