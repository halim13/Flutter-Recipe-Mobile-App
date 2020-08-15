import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../widgets/text.form.ingredients.add.dart';
import '../widgets/text.form.steps.add.dart';
import '../providers/recipe.add.dart';

class AddRecipeScreen extends StatefulWidget {
  static const routeName = '/add-recipe';
  @override
  _AddRecipeState createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipeScreen> { 
  void changeImageRecipe() async {
    ImageSource imageSource = await showDialog<ImageSource>(context: context, builder: (context) => 
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
      )
    );
    if(imageSource != null) {
      RecipeAdd recipeProvider = Provider.of<RecipeAdd>(context, listen: false);
      PickedFile pickedFile = await ImagePicker().getImage(source: imageSource);
      recipeProvider.changeImageRecipe(pickedFile);
    }
  }

  void save(BuildContext context) async {
    RecipeAdd recipeProvider = Provider.of<RecipeAdd>(context, listen: false);
    recipeProvider.titleFocusNode.unfocus();
    try {
      if(recipeProvider.titleController.text == "") {
        recipeProvider.titleFocusNode.requestFocus();
        throw new Exception('Hari ini mau masak apa ?');
      } 
      for (int i = 0; i < recipeProvider.ingredientsGroup.length; i++) {
        TextEditingController ingredientsGroupController = recipeProvider.ingredientsGroup[i].textEditingController;
        if(ingredientsGroupController.text == "") {
          FocusNode node = recipeProvider.ingredientsGroup[i].focusNode;
          node.requestFocus();
          throw new Exception('Oops! lupa diisi ya ?');
        }
        for (int z = 0; z < recipeProvider.ingredientsGroup[i].ingredients.length; z++) {
          TextEditingController ingredientsController = recipeProvider.ingredientsGroup[i].ingredients[z].textEditingController;
          if(ingredientsController.text == "") {
            FocusNode node = recipeProvider.ingredientsGroup[i].ingredients[z].focusNode;
            node.requestFocus();
            throw new Exception('Oops! lupa diisi ya ?');
          }
          recipeProvider.ingredientsGroupSendToHttp.add({
            "uuid": recipeProvider.ingredientsGroup[i].uuid,
            "item": ingredientsGroupController.text,
          });
          recipeProvider.ingredientsSendToHttp.add({
            "uuid": recipeProvider.ingredientsGroup[i].ingredients[z].uuid,
            "ingredient_group_id": recipeProvider.ingredientsGroup[i].uuid,
            "item": ingredientsController.text
          });
        }
      }
      for (int i = 0; i < recipeProvider.steps.length; i++) {
        TextEditingController stepsController = recipeProvider.steps[i].textEditingController;
        if(stepsController.text == "") {
          FocusNode node = recipeProvider.steps[i].focusNode;
          node.requestFocus();
          throw new Exception('Oops! lupa diisi ya ?');
        }
        recipeProvider.stepsSendToHttp.add({
          "uuid": recipeProvider.steps[i].uuid,
          "item": stepsController.text
        });
      }
      Set<dynamic> seenIngredientsGroup = Set();
      Set<dynamic> seenIngredients = Set();
      Set<dynamic> seenSteps = Set();
      List<Map<String, dynamic>> uniqueIngredientsGroup = recipeProvider.ingredientsGroupSendToHttp.where((item) => seenIngredientsGroup.add(item["uuid"])).toList();
      List<Map<String, dynamic>> uniqueIngredients = recipeProvider.ingredientsSendToHttp.where((item) => seenIngredients.add(item["uuid"])).toList();
      List<Map<String, dynamic>> uniqueSteps = recipeProvider.stepsSendToHttp.where((item) => seenSteps.add(item["uuid"])).toList();
      String title = recipeProvider.titleController.text;
      String ingredientsGroup = jsonEncode(uniqueIngredientsGroup);
      String ingredients = jsonEncode(uniqueIngredients);
      String steps = jsonEncode(uniqueSteps);
      await recipeProvider.store(title, ingredientsGroup, ingredients, steps);
    } on Exception catch(error) {
      String errorSplit = error.toString();
      List<String> errorText = errorSplit.split(":");
      SnackBar snackbar = SnackBar(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buat Resep'),
      ),
      body: ListView(
        children: [
           Stack(
            overflow: Overflow.visible,
            alignment: Alignment.center,
            children: [
              Consumer<RecipeAdd>(
                builder: (context, value, child) {
                return SizedBox(
                    width: double.infinity,
                    height: 300.0,
                    child: value.fileImageRecipe == null ? Column(
                      children: [ 
                        Image.asset('assets/default-thumbnail.jpg')
                      ]
                    )
                    : Image.file(
                    value.fileImageRecipe,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 300.0,
                  ),
                  );
                }, 
              ),
              Positioned(
                child: IconButton(
                  color: Colors.brown[300],
                  icon: Icon(Icons.camera_alt), 
                  onPressed: changeImageRecipe
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
          Consumer<RecipeAdd>(
            builder: (context, value, child) { 
              return Container(
                child: Form(
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(left: 18.0, right: 18.0),
                    child: TextFormField(
                      focusNode: value.titleFocusNode,
                      controller: value.titleController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ) 
                      ),       
                    )
                  ),
                ),
              );
            }
          ),
          Container(
            margin: EdgeInsets.only(left: 18.0, top: 20.0, right: 18.0, bottom: 5.0),
            child: Text(
              'Kategori apa ?',
              style: TextStyle(
                fontSize: 15.0
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 18.0, top: 15.0, right: 18.0),
            child: Column(
              children: [
                Consumer<RecipeAdd>(
                  builder: (context, value, child) => DropdownSearch(
                    mode: Mode.BOTTOM_SHEET,
                    items: value.categoriesDisplay,
                    label: "Pilih Kategori",
                    onChanged: (v) {
                      value.categoryName = v;
                    },
                    selectedItem: value.categoryName
                  ),
                )
              ]
            )
          ),
          Container(
            margin: EdgeInsets.only(left: 18.0, top: 20.0, right: 18.0, bottom: 10.0),
            child: Text(
              'Berapa lama memasak ini ?',
              style: TextStyle(
                fontSize: 15.0
              ),
            ),
          ),
          Container(
            height: 220.0,
            child: Consumer<RecipeAdd>(
              builder: (context, value, child) {
              return CupertinoTimerPicker(
                backgroundColor: Colors.grey[300],
                mode: CupertinoTimerPickerMode.hm,
                  onTimerDurationChanged: (val) {
                    value.duration = val;
                  },
                );
              }
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
            width: double.infinity,
            child: textFormIngredientsAdd()
          ),
          Container(
            margin: EdgeInsets.only(left: 10.0, right: 10.0),
            padding: EdgeInsets.all(10.0),
            width: double.infinity,
            child: Consumer<RecipeAdd>(
              builder: (context, value, child) {
                return RaisedButton(
                  elevation: 0.0,
                  color: Colors.brown[300],
                  child: Text(
                    'Tambah grup',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0
                    ),
                  ),
                  onPressed: () => value.incrementIngredientPerGroup()
                );
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 18.0, top: 20.0, right: 18.0),
            child: Text(
              'Bagaimana Memasak nya ?',
              style: TextStyle(
                fontSize: 15.0
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(10.0),
            padding: EdgeInsets.all(10.0),
            width: double.infinity,
            child: textFormStepsAdd(context)
          ),
          Container(
            margin: EdgeInsets.all(10.0),
            padding: EdgeInsets.all(10.0),
            width: double.infinity,
            child: Consumer<RecipeAdd>(
              builder: (context, value, child) {
                return RaisedButton(
                  elevation: 0.0,
                  color: Colors.brown[300],
                  child: Text('Tambah langkah', 
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0
                    ),  
                  ),
                  onPressed: () => value.incrementSteps()
                ); 
              }
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            width: double.infinity,
            child: Consumer<RecipeAdd>(
              builder: (context, value, child) {
                return RaisedButton(
                child: value.isLoading ? SizedBox(
                    height: 20.0,
                    width: 20.0,
                    child: CircularProgressIndicator()
                  ) : Text('Simpan perubahan', 
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
                );
              },
            ),
          )
        ]
      ),
    );
  }
}
