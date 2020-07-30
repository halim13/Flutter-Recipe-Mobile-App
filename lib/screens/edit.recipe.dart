import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/models/Company.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/url.dart';
import '../providers/recipe.dart';
import './recipe.detail.dart';

class EditRecipeScreen extends StatefulWidget {
  static const routeName = '/edit-recipe-screen';
  @override
  _EditRecipeScreenState createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  Timer timer;

  void pickImage(int i, int z) async {
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
      PickedFile pickedFile = await ImagePicker().getImage(source: imageSource);
      recipe.stepsImage(i, z, pickedFile);
    }
  }
  void save(context) async {
    final recipe = Provider.of<Recipe>(context, listen: false);
    recipe.formTitleKey.currentState.save();
    recipe.formIngredientsKey.currentState.save();
    recipe.formStepsKey.currentState.save();
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
        recipe.initialIngredients.add({
          "uuid": recipe.ingredients[i].uuid,
          "item": controller.text
        });
      }
      for (int i = 0; i < recipe.steps.length; i++) {
        TextEditingController controller = recipe.controllerSteps[i]["item"];
        if(controller.text == "") {
          FocusNode node = recipe.focusStepsNode[i]["item"];
          node.requestFocus();
          throw new Exception('Bagaimana cara memasaknya ?');
        }
        for (int z = 0; z < recipe.steps[i].images.length; z++) {
          recipe.initialSteps.add({
            "uuid": recipe.steps[i].uuid,
            "item": controller.text
          });
        }
      }
      final seenRemoveIngredients = Set();
      final seenRemoveSteps = Set();
      final seenIngredients = Set();
      final seenSteps = Set();
      final uniqueRemoveIngredients = recipe.valueIngredientsRemove.where((item) => seenRemoveIngredients.add(item["uuid"])).toList();
      final uniqueRemoveSteps = recipe.valueStepsRemove.where((item) => seenRemoveSteps.add(item["uuid"])).toList();
      final uniqueIngredients = recipe.initialIngredients.where((item) => seenIngredients.add(item["uuid"])).toList();
      final uniqueSteps = recipe.initialSteps.where((item) => seenSteps.add(item["uuid"])).toList();
      final removeIngredients = jsonEncode(uniqueRemoveIngredients);
      final removeSteps = jsonEncode(uniqueRemoveSteps);
      final ingredients = jsonEncode(uniqueIngredients);
      final steps = jsonEncode(uniqueSteps);
      final recipeId = ModalRoute.of(context).settings.arguments;
      await Provider.of<Recipe>(context, listen: false).update(recipe.titleController.text, recipeId, ingredients, steps, removeIngredients, removeSteps, '054ba002-0122-496b-937e-32d05acef05c');
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
          RecipeDetailScreen.routeName, 
          arguments: recipeId
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
        actions: [
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

  @override
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
  Widget build(BuildContext context) {
    final recipeId = ModalRoute.of(context).settings.arguments;
    final recipe = Provider.of<Recipe>(context, listen: false);
    return FutureBuilder(
      future: Provider.of<Recipe>(context, listen: false).edit(recipeId),
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          color: Colors.brown[300],
                          icon: Icon(Icons.camera_alt), 
                          onPressed: null
                        )
                      )
                    ]
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 18.0, top: 20.0, right: 18.0),
                    child: Text(
                      'Kamu ingin buat masakan apa ?',
                      style: TextStyle(
                        fontSize: 15.0
                      ),
                    ),
                  ),
                  Form(
                    key: recipe.formTitleKey,
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 18.0, right: 18.0),
                      child: TextFormField(
                        focusNode: recipe.titleFocusNode,
                        controller: recipe.titleController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
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
                    margin: EdgeInsets.only(left: 18.0, top: 20.0, right: 18.0),
                    child: Text(
                      'Kategori',
                      style: TextStyle(
                        fontSize: 15.0
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 18.0, top: 15.0, right: 18.0),
                    child: Column(
                      children: [
                        Consumer<Recipe>(
                          builder: (context, value, child) => DropdownSearch(
                            mode: Mode.BOTTOM_SHEET,
                            showSelectedItem: true,
                            items: value.categoriesDisplay,
                            label: "Pilih Kategori",
                            onChanged: (value) {
                              
                            },
                            selectedItem: value.categoryName
                          ),
                        )
                      ]
                    )
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 18.0, top: 20.0, right: 18.0),
                    child: Text(
                      'Apa saja bahan - bahan nya ?',
                      style: TextStyle(
                        fontSize: 15.0
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    margin: EdgeInsets.all(18.0),
                    padding: EdgeInsets.all(18.0),
                    height: 150.0,
                    width: double.infinity,
                    child: formIngredientsEdit()
                  ),
                  Container(
                    margin: EdgeInsets.all(10.0),
                    padding: EdgeInsets.all(10.0),
                    width: double.infinity,
                    child: Consumer<Recipe>(
                      builder: (context, recipe, child) {
                        return RaisedButton(
                          elevation: 0.0,
                          color: Colors.brown[300],
                          child: Text(
                            'Tambah bahan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0
                            ),  
                          ),
                          onPressed: () => recipe.incrementsIngredients()
                        );
                      }
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 18.0, top: 20.0, right: 18.0),
                    child: Text(
                      'Bagaimana Memasaknya ?',
                      style: TextStyle(
                        fontSize: 15.0
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10.0),
                    padding: EdgeInsets.all(10.0),
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
                          color: Colors.brown[300],
                          child: Text('Tambah langkah', 
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0
                            ),  
                          ),
                          onPressed: () => recipe.incrementsSteps()
                        );
                      }
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(10.0),
                    padding: EdgeInsets.all(10.0),
                    child: Builder(
                      builder: (context) => 
                        RaisedButton(
                        child: Text(
                          'Ubah Resep',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.0
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(color: Colors.white)
                        ),
                        elevation: 0.0,
                        color: Colors.blue[300],
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

  Widget formIngredientsEdit() {
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
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: i > 0 ? Colors.grey : Colors.white,
                      ),
                      onPressed: () { 
                        if(i > 0) {
                          recipe.decrementIngredients(recipe.ingredients[i].uuid);
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
                    ),
                ),
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
        return Form(
          key: recipe.formStepsKey,
          child: Column(  
            children: List.generate(recipe.steps.length, (i) {
              return Container(
                 margin: EdgeInsets.only(top: 20.0),
                 child: Column(  
                  children: [
                    TextFormField(
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 15.0
                      ),
                      focusNode: recipe.focusStepsNode[i]["item"],
                      controller: recipe.controllerSteps[i]["item"],
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 15.0
                        ),
                        hintText: "Bagaimana langkah membuatnya?",
                        prefixIcon: Column( 
                          children: [  
                            Text(
                              '${i + 1}.', 
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 19.0,
                              )
                            )
                          ]
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: i > 0 ? Colors.grey : Colors.white,
                          ),
                          onPressed: () {
                            if(i > 0) {
                              recipe.decrementSteps(recipe.steps[i].uuid);
                            } else {
                              return null;
                            }
                          },
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ) 
                      ),
                    ),
                    Row(
                      children: List.generate(recipe.steps[i].images.length, (z) =>
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(top: 10.0),
                            height: 100.0,
                            child: InkWell( 
                              child: recipe.steps[i].images[z].body,                                                   
                              onTap: () => pickImage(i, z)
                            ),
                          )
                        )
                      )
                    )
                  ]
                ),
              );
            })
          )
        );
      }
    );
  }
}