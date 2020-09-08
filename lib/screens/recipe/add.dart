import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import '../../widgets/text.form.ingredients.add.dart';
import '../../widgets/text.form.steps.add.dart';
import '../../providers/recipe/add.dart';

class AddRecipeScreen extends StatefulWidget {
  @override
  _AddRecipeState createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipeScreen> { 
  ConnectivityResult connectionStatus;
  Connectivity connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> connectivitySubscription;
  bool isInAsyncCall = false;
  Timer timer;

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
      RecipeAdd recipeProvider = Provider.of<RecipeAdd>(context, listen: false);
      PickedFile pickedFile = await ImagePicker().getImage(
        source: imageSource,
        maxHeight: 480, 
        maxWidth: 640
      );
      recipeProvider.changeImageRecipe(pickedFile);
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

  void save(BuildContext context, [int isPublished = 1]) async {
    RecipeAdd recipeProvider = Provider.of<RecipeAdd>(context, listen: false);
    recipeProvider.titleFocusNode.unfocus();
    try {       
      if(recipeProvider.titleController.text == "") {
        FocusNode node = recipeProvider.titleFocusNode;
        node.requestFocus();
        throw new Exception('Title Recipe is required');
      } 
      if(recipeProvider.duration == null) {
        throw new Exception('Duration is required');
      }
      for (int i = 0; i < recipeProvider.ingredientsGroup.length; i++) {
        TextEditingController ingredientsGroupController = recipeProvider.ingredientsGroup[i].textEditingController;
        if(ingredientsGroupController.text == "") {
          FocusNode node = recipeProvider.ingredientsGroup[i].focusNode;
          node.requestFocus();
          throw new Exception('Title Ingredients Group is required');
        }
        for (int z = 0; z < recipeProvider.ingredientsGroup[i].ingredients.length; z++) {
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
      setState(() => isInAsyncCall = true );
      final response = await recipeProvider.store(title, ingredientsGroup, ingredients, steps, isPublished);
     if(response["status"] == 200) {
        setState(() => isInAsyncCall = false );
        AwesomeDialog(
          context: context,
          animType: AnimType.BOTTOMSLIDE,
          headerAnimationLoop: false,
          dismissOnTouchOutside: false,
          dialogType: response["data"] == "ALERTDEMO" ? DialogType.INFO : DialogType.SUCCES,
          title: response["data"] == "ALERTDEMO" ? 'Info' : 'Successful',
          desc: response["data"] == "ALERTDEMO" ? 'for DEMO \n Account is not Allow more 6 Recipes' : isPublished == 1 ? 'Recipe Created' : 'Saved to Draft',
          btnOkOnPress: () => Navigator.of(context).pop(),
          btnOkIcon: null,
          btnOkColor: Colors.blue.shade700
        )..show();
      }
    } on SocketException catch(_) {
      setState(() => isInAsyncCall = false );
      if(isPublished == 1) {
        setState(() => Provider.of<RecipeAdd>(context, listen: false).isLoading = false );
      } else {
        setState(() => Provider.of<RecipeAdd>(context, listen: false).isLoadingDraft = false );
      }
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
      setState(() => isInAsyncCall = false );
      if(isPublished == 1) {
        setState(() => Provider.of<RecipeAdd>(context, listen: false).isLoading = false );
      } else {
        setState(() => Provider.of<RecipeAdd>(context, listen: false).isLoadingDraft = false );
      }
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

  Future<void> updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        setState(() => connectionStatus = result);
      break;
      case ConnectivityResult.mobile:
        setState(() => connectionStatus = result);
      break;
      case ConnectivityResult.none:
        setState(() => connectionStatus = result);
      break;
      default:
    }
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();
    connectivitySubscription = connectivity.onConnectivityChanged.listen(updateConnectionStatus);
  } 

  @override
  void dispose() {
    connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }
    if (!mounted) {
      return Future.value(null);
    }
    return updateConnectionStatus(result);
  }
  Widget build(BuildContext context) {
    bool isLoading = Provider.of<RecipeAdd>(context, listen: false).isLoading;
    bool isLoadingDraft = Provider.of<RecipeAdd>(context, listen: false).isLoadingDraft;
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Recipe'),
        leading: isLoading || isLoadingDraft
        ? IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
          ) 
        : IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(true)
        ),
      ),
      body: connectionStatus == ConnectivityResult.none ? showError() : getAddPage()
    );
  }

  Widget showError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150.0,
            child: Image.asset('assets/no-network.png')
          ),
          SizedBox(height: 15.0),
          Text('Bad Connection or Server Unreachable',
            style: TextStyle(
              fontSize: 16.0
            ),
          ),
          SizedBox(height: 10.0),
          GestureDetector(
            child: Text('Try Again',
              style: TextStyle(
                fontSize: 16.0,
                decoration: TextDecoration.underline
              ),
            ),
            onTap: () {
              setState((){});
            },
          ),
        ],
      ),
    );
  }

  Widget getAddPage() {
    return ModalProgressHUD(
      inAsyncCall: isInAsyncCall,
      progressIndicator: Container(),
      opacity: 0.5,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              overflow: Overflow.visible,
              alignment: Alignment.center,
              children: [
                Consumer<RecipeAdd>(
                  builder: (BuildContext context, RecipeAdd recipeProvider, Widget child) {
                  return SizedBox(
                    width: double.infinity,
                    child: recipeProvider.fileImageRecipe == null 
                    ? Column(
                        children: [ 
                          Image.asset('assets/default-thumbnail.jpg')
                        ]
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
            Consumer<RecipeAdd>(
              builder: (BuildContext context, RecipeAdd recipeProvider, Widget child) { 
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
                    )
                  ),
                );
              }
            ),
            title('What are the Category ?'),
            Container(
              margin: EdgeInsets.only(left: 18.0, top: 15.0, right: 18.0),
              child: Column(
                children: [
                  Consumer<RecipeAdd>(
                    builder: (BuildContext context, RecipeAdd recipeProvider, Widget child) => DropdownSearch(
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
              margin: EdgeInsets.only(left: 18.0, top: 15.0, right: 18.0),
              child: Column(
                children: [
                  Consumer<RecipeAdd>(
                    builder: (BuildContext context, RecipeAdd recipeProvider, Widget child) => DropdownSearch(
                      mode: Mode.BOTTOM_SHEET,
                      items: recipeProvider.foodCountriesDisplay,
                      label: "Country",
                      onChanged: (value) {
                        recipeProvider.foodCountryName = value;
                      },
                      selectedItem: recipeProvider.foodCountryName
                    ),
                  )
                ]
              )
            ),
            title('How many portion'),
            Container(
              margin: EdgeInsets.only(left: 18.0, top: 15.0, right: 18.0),
              child: Column(
                children: [
                  Consumer<RecipeAdd>(
                    builder: (BuildContext context, RecipeAdd recipeProvider, Widget child) => DropdownSearch(
                      mode: Mode.BOTTOM_SHEET,
                      items: recipeProvider.portionsDisplay,
                      label: "Portion",
                      onChanged: (value) {
                        recipeProvider.portionName = value;
                      },
                      selectedItem: recipeProvider.portionName
                    ),
                  )
                ]
              )
            ),
            title('How long to Cook this ?'),
            Container(
              height: 220.0,
              child: Consumer<RecipeAdd>(
                builder: (context, value, child) {
                return CupertinoTimerPicker(
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
                builder: (BuildContext context, RecipeAdd recipeProvider, Widget child) {
                  return RaisedButton(
                    child: Text(
                      'Add Group',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0
                      ),
                    ),
                    elevation: 0.0,
                    color: Colors.brown.shade700,
                    onPressed: () => recipeProvider.incrementIngredientPerGroup(context)
                  );
                },
              ),
            ),
            title('How to Cook ?'),
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
                builder: (BuildContext context, RecipeAdd recipeProvider, Widget child) {
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
                    onPressed: () => recipeProvider.incrementSteps(context)
                  ); 
                }
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              width: double.infinity,
              child: Consumer<RecipeAdd>(
                builder: (BuildContext context, RecipeAdd recipeProvider, Widget child) {
                  return Container(
                    height: 48.0,
                    child: recipeProvider.isLoading ? 
                    RaisedButton(
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
                        side: BorderSide(color: Colors.white)
                      ),
                      elevation: 0.0,
                      color: Colors.blue.shade700,
                      onPressed: () {},
                    )
                    : RaisedButton(
                      child: Text('Create', 
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
                      onPressed: () => save(context),
                    ),
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
              width: double.infinity,
              child: Consumer<RecipeAdd>(
                builder: (BuildContext context, RecipeAdd recipeProvider, Widget child) {
                  return Container(
                    height: 48.0,
                    child: recipeProvider.isLoadingDraft ? 
                    RaisedButton(
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
                        side: BorderSide(color: Colors.white)
                      ),
                      elevation: 0.0,
                      color: Colors.blue.shade700,
                      onPressed: () {},
                    )
                    : RaisedButton(
                      child: Text('Save to Draft', 
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
                    ),
                  );
                },
              ),
            )
          ]
        )
      ),
    );
  }
}
