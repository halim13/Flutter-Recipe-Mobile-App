import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import '../../widgets/text.form.ingredients.edited.dart';
import '../../widgets/text.form.steps.edited.dart';
import '../../constants/url.dart';
import '../../helpers/show.error.dart';
import '../../providers/recipe/edit.dart';

class EditRecipeScreen extends StatefulWidget {
  @override
  _EditRecipeScreenState createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {

  void changeImageRecipe() async {
    ImageSource imageSource = await showDialog<ImageSource>(context: context, builder: (context) => 
      AlertDialog(
        title: Text("Select Image Source",
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
      RecipeEdit recipe = Provider.of<RecipeEdit>(context, listen: false);
      PickedFile pickedFile = await ImagePicker().getImage(
        source: imageSource,
        maxHeight: 480, 
        maxWidth: 640
      );
      recipe.changeImageRecipe(pickedFile);
    }
  }

  Widget title(String title) {
    return Container(
      margin: EdgeInsets.only(left: 18.0, top: 20.0, right: 18.0, bottom: 20.0),
      child: Text(title,
        style: TextStyle(
          fontSize: 16.0,
          fontStyle: FontStyle.italic
        ),
      ),
    );
  }

  void save(BuildContext context, [int isPublished = 0]) async {
    RecipeEdit recipeProvider = Provider.of<RecipeEdit>(context, listen: false);
    String msg = Provider.of<RecipeEdit>(context, listen: false).msg;
    recipeProvider.titleFocusNode.unfocus();
    try {
      if(recipeProvider.titleController.text == "") {
        recipeProvider.titleFocusNode.requestFocus();
        throw new Exception('Title Recipe is required');
      }
      if(recipeProvider.portionName == null) {
        throw new Exception('Portion is required');
      } 
      if(recipeProvider.duration == "0") {
         throw new Exception('Duration is required');
      }
      for (int i = 0; i < recipeProvider.ingredientsGroup.length; i++) {
        TextEditingController ingredientsGroupController = recipeProvider.ingredientsGroup[i].textEditingController;
        if(ingredientsGroupController.text == "") {
          FocusNode node = recipeProvider.ingredientsGroup[i].focusNode;
          node.requestFocus();
          throw new Exception('Title Ingredients Group is required');
        }
        for(int z = 0; z < recipeProvider.ingredientsGroup[i].ingredients.length; z++) {
          TextEditingController ingredientsController = recipeProvider.ingredientsGroup[i].ingredients[z].textEditingController;
          if(ingredientsController.text == "") {
            FocusNode node = recipeProvider.ingredientsGroup[i].ingredients[z].focusNode;
            node.requestFocus();
            throw new Exception('Title Ingredients is required');
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
          throw new Exception('How to Cook ?');
        }
        recipeProvider.stepsSendToHttp.add({
          "uuid": recipeProvider.steps[i].uuid,
          "item": stepsController.text
        });
      }
      switch (isPublished) {
        case 2:
          msg = 'Updated';
          isPublished = 1;
        break;
        case 1:
          msg = 'Published';
        break;
        case 0:
          msg = 'Saved to Draft';
        break;
        default:
      }
      String categoryName = recipeProvider.categoryName;
      Set<dynamic> seenIngredientsGroup = Set();
      Set<dynamic> seenRemoveIngredientsGroup = Set();
      Set<dynamic> seenIngredients = Set();
      Set<dynamic> seenRemoveIngredients = Set();
      Set<dynamic> seenSteps = Set();
      Set<dynamic> seenRemoveSteps = Set();
      List<Map<String, Object>> uniqueIngredientsGroup = recipeProvider.ingredientsGroupSendToHttp.where((item) => seenIngredientsGroup.add(item["uuid"])).toList();
      List<Map<String, Object>> uniqueRemoveIngredientsGroup = recipeProvider.removeIngredientsGroupSendToHttp.where((item) => seenRemoveIngredientsGroup.add(item["uuid"])).toList();
      List<Map<String, Object>> uniqueIngredients = recipeProvider.ingredientsSendToHttp.where((item) => seenIngredients.add(item["uuid"])).toList();
      List<Map<String, Object>> uniqueRemoveIngredients = recipeProvider.removeIngredientsSendToHttp.where((item) => seenRemoveIngredients.add(item["uuid"])).toList();
      List<Map<String, Object>> uniqueSteps = recipeProvider.stepsSendToHttp.where((item) => seenSteps.add(item["uuid"])).toList();
      List<Map<String, Object>> uniqueRemoveSteps = recipeProvider.removeStepsSendToHttp.where((item) => seenRemoveSteps.add(item["uuid"])).toList();
      String title = recipeProvider.titleController.text;
      String ingredientsGroup = jsonEncode(uniqueIngredientsGroup);
      String removeIngredientsGroup = jsonEncode(uniqueRemoveIngredientsGroup);
      String ingredients = jsonEncode(uniqueIngredients);
      String removeIngredients = jsonEncode(uniqueRemoveIngredients);
      String steps = jsonEncode(uniqueSteps);
      String removeSteps = jsonEncode(uniqueRemoveSteps);
      Map<String, String> routeArgs = ModalRoute.of(context).settings.arguments;
      String recipeId = routeArgs["recipeId"];
      String categoryId = routeArgs["categoryId"];
      final response = await Provider.of<RecipeEdit>(context, listen: false).update(
        context, 
        title, 
        recipeId, 
        categoryId,
        ingredientsGroup, 
        removeIngredientsGroup, 
        ingredients, 
        removeIngredients, 
        steps, 
        removeSteps, 
        categoryName,
        isPublished
      );
      if(response["status"] == 200) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.SUCCES,
          animType: AnimType.BOTTOMSLIDE,
          headerAnimationLoop: false,
          dismissOnTouchOutside: false,
          title: 'Successful',
          desc: msg,
          btnOkOnPress: () {
            Navigator.pop(context, title);
          },
          btnOkIcon: null,
          btnOkColor: Colors.blue.shade700
        )..show();
      } 
    } on SocketException catch(_) {
      setState(() => Provider.of<RecipeEdit>(context, listen: false).isLoading = false);
      SnackBar snackbar = SnackBar(
        backgroundColor: Colors.red[300],
        content: Text('Connection Bad or Server Unreachable'),
        action: SnackBarAction(
          textColor: Colors.white,
          label: 'Close',
          onPressed: () {
            Scaffold.of(context).hideCurrentSnackBar();
          }
        ),
      );
      Scaffold.of(context).showSnackBar(snackbar);
    } on Exception catch(error) { 
      Provider.of<RecipeEdit>(context, listen: false).isLoading = false;
      String errorSplit = error.toString();
      List<String> errorText = errorSplit.split(":");
      SnackBar snackbar = SnackBar(
        backgroundColor: Colors.red[300],
        content: Text(errorText[1]),
        action: SnackBarAction(
          textColor: Colors.white,
          label: 'Close',
          onPressed: () {
            Scaffold.of(context).hideCurrentSnackBar();
          }
        ),
      );
      Scaffold.of(context).showSnackBar(snackbar);
    }
  }
  
  Future<bool> onWillPop() async {
    bool isLoading = Provider.of<RecipeEdit>(context, listen: false).isLoading;
    return isLoading ? Container() : await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Cancel ?', style: TextStyle(color: Colors.black)),
        content: Text('Data is not save if you exit'),
        actions: [
          FlatButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No'),
          ),
          FlatButton(
            onPressed: () { 
              Navigator.popUntil(context, ModalRoute.withName('/detail-recipe'));
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }
  refresh() {
    setState((){});
  }
  @override
  Widget build(BuildContext context) {
    Map<String, String> routeArgs = ModalRoute.of(context).settings.arguments;
    String recipeId = routeArgs["recipeId"];
    return Scaffold(
    appBar: AppBar(
      title: Text('Edit Recipe'),
    ),
    body: WillPopScope(
      onWillPop: onWillPop,
      child: FutureBuilder(
        future: Provider.of<RecipeEdit>(context, listen: false).edit(recipeId),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator()
            );
          }
          if(snapshot.hasError) {
            return ShowError(
              notifyParent: refresh,
            );
          }
          return Consumer<RecipeEdit>(
            builder: (BuildContext context, RecipeEdit recipeEdit, Widget child) => ModalProgressHUD(
              inAsyncCall: recipeEdit.isLoading,
              opacity: 0.5,
              progressIndicator: Container(),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Stack(
                    overflow: Overflow.visible,
                    alignment: Alignment.center,
                    children: [
                      Consumer<RecipeEdit>(
                        builder: (context, recipeProvider, child) {
                          return SizedBox(
                            width: double.infinity,
                            height: 300.0,
                            child: recipeProvider.fileImageRecipe == null 
                            ? CachedNetworkImage(
                                imageUrl: '$imagesRecipesUrl/${recipeProvider.getFileImageRecipe}',
                                imageBuilder: (context, imageProvider) => Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) => Image.asset('assets/default-thumbnail.jpg'),
                                errorWidget: (context, url, error) => Image.asset('assets/default-thumbnail.jpg'),
                              ) 
                            : Image.file(
                              recipeProvider.fileImageRecipe,
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
                  title('What are you Cook ?'),
                  Consumer<RecipeEdit>(
                    builder: (context, recipeProvider, child) {
                      return Form(
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(left: 18.0, right: 18.0),
                          child: TextFormField(
                            focusNode: recipeProvider.titleFocusNode,
                            controller: recipeProvider.titleController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ) 
                            ),
                            onSaved: (val) {
                              recipeProvider.titleController.text = val;
                            },
                          ),
                        ),
                      );
                    }
                  ),
                  title('What are the Category ?'),
                  Container(
                    margin: EdgeInsets.only(left: 18.0, right: 18.0),
                    child: Column(
                      children: [
                        Consumer<RecipeEdit>(
                          builder: (BuildContext context, RecipeEdit recipeProvider, Widget child) => DropdownSearch(
                            mode: Mode.BOTTOM_SHEET,
                            items: recipeProvider.categoriesDisplay,
                            label: "Category",
                            onChanged: (value) {
                              recipeProvider.categoryName = value;
                            },
                            selectedItem: recipeProvider.categoryName
                          ),
                        )
                      ]
                    )
                  ),
                  title('Where this food come from ?'),
                  Container(
                    margin: EdgeInsets.only(left: 18.0, right: 18.0),
                    child: Column(
                      children: [
                        Consumer<RecipeEdit>(
                          builder: (BuildContext context, RecipeEdit recipeProvider, Widget child) => DropdownSearch(
                            mode: Mode.BOTTOM_SHEET,
                            items: recipeProvider.foodCountriesDisplay,
                            label: "Country",
                            onChanged: (v) {
                              recipeProvider.foodCountryName = v;
                            },
                            selectedItem: recipeProvider.foodCountryName
                          ),
                        )
                      ]
                    )
                  ),
                  title('How many Portion ?'),
                  Container(
                    margin: EdgeInsets.only(left: 18.0, right: 18.0),
                    child: Column(
                      children: [
                        Consumer<RecipeEdit>(
                          builder: (BuildContext context, RecipeEdit recipeProvider, Widget child) => DropdownSearch(
                            mode: Mode.BOTTOM_SHEET,
                            showSelectedItem: true,
                            items: recipeProvider.portionsDisplay,
                            label: "Portion",
                            onChanged: (v) {
                              recipeProvider.portionName = v;
                            },
                            selectedItem: recipeProvider.portionName
                          ),
                        )
                      ]
                    )
                  ),
                  title('How long to Cook this ?'),
                  Container(
                    margin: EdgeInsets.only(left: 18.0, right: 18.0),
                    height: 200.0,
                    child: Consumer<RecipeEdit>(
                      builder: (context, value, child) {
                      return CupertinoTimerPicker(
                        initialTimerDuration: Duration(minutes: int.parse(value.duration)),
                        backgroundColor: Colors.grey[300],
                        mode: CupertinoTimerPickerMode.hm,
                          onTimerDurationChanged: (val) {
                            value.duration = val.inMinutes.toString();
                          },
                        );
                      }
                    )
                  ),
                  title('What are the Ingredients ?'),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(left: 18.0, right: 18.0),
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: textFormIngredientsEdit(context)
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(left: 18.0, right: 18.0),
                    padding: EdgeInsets.all(10.0),
                    child: Consumer<RecipeEdit>(
                      builder: (context, recipeProvider, child) {
                        return RaisedButton(
                          child: Text(
                            'Add Group',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(color: Colors.transparent)
                          ),
                          elevation: 0.0,
                          color: Colors.brown.shade700,
                          onPressed: () => recipeProvider.incrementIngredientsPerGroup(context)
                        );
                      },
                    ),
                  ),
                  title('How to Cook ?'),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(left: 18.0, right: 18.0),
                    padding: EdgeInsets.all(10.0),
                    child: textFormStepsEdited(context)
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(10.0),
                    padding: EdgeInsets.all(10.0),
                    child: Consumer<RecipeEdit>(
                      builder: (context, recipeProvider, child) {
                        return RaisedButton(
                          child: Text('Add Steps', 
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0
                            ),  
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(color: Colors.transparent)
                          ),
                          elevation: 0.0,
                          color: Colors.brown.shade700,
                          onPressed: () => recipeProvider.incrementsSteps(context)
                        );
                      }
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(10.0),
                    padding: EdgeInsets.all(10.0),
                      child: Consumer<RecipeEdit>(
                        builder: (BuildContext context, RecipeEdit recipeProvider, Widget child) {
                          return Container(
                            height: 48.0,
                            child: recipeProvider.isLoading 
                            ? RaisedButton(
                              child: Center(
                                child: SizedBox(
                                  height: 30.0,
                                  width: 30.0,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(color: Colors.transparent)
                              ),
                              elevation: 0.0,
                              color: Colors.blue.shade700,
                              onPressed: () {},
                            ) 
                          : recipeProvider.data.recipes.first.isPublished == 1 
                                  ? RaisedButton(
                                      child: Text(
                                        'Update',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0
                                        ),
                                      ) ,
                                      shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      side: BorderSide(color: Colors.transparent)
                                    ),
                                    elevation: 0.0,
                                    color: Colors.blue.shade700,
                                    onPressed: () => save(context, 2),  
                                  )
                                :  RaisedButton(
                                    child: Text('Publish',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0
                                      ),
                                    ) ,
                                    shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    side: BorderSide(color: Colors.transparent)
                                  ),
                                  elevation: 0.0,
                                  color: Colors.blue.shade700,
                                  onPressed: () => save(context, 1),  
                                )
                              );
                            }
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                          padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                          child: Consumer<RecipeEdit>(
                           builder: (BuildContext context, RecipeEdit recipeProvider, Widget child) =>Container(
                              height: 48.0,
                              child: recipeProvider.isLoadingDraft 
                              ? RaisedButton(
                                  child: Center(
                                    child: SizedBox(
                                      height: 30.0,
                                      width: 30.0,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    side: BorderSide(color: Colors.transparent)
                                  ),
                                  elevation: 0.0,
                                  color: Colors.blue.shade700,
                                  onPressed: () {},
                                ) 
                              : RaisedButton(
                                child: Text(
                                  'Save to Draft',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: BorderSide(color: Colors.transparent)
                                ),
                                elevation: 0.0,
                                color: Colors.blue.shade700,
                                onPressed: () => save(context, 0),  
                              )
                            ),
                        ),
                      )
                    ],
                  )
                ),
              ),
            );
          },
        ),
      )
    );
  }
}