import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../widgets/text.form.ingredients.edited.dart';
import '../widgets/text.form.steps.edited.dart';
import '../constants/url.dart';
import '../providers/recipe.edit.dart';

class EditRecipeScreen extends StatefulWidget {
  static const routeName = '/edit-recipe-screen';
  @override
  _EditRecipeScreenState createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  Timer timer;

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
      RecipeEdit recipe = Provider.of<RecipeEdit>(context, listen: false);
      PickedFile pickedFile = await ImagePicker().getImage(source: imageSource);
      recipe.changeImageRecipe(pickedFile);
    }
  }

  void save(BuildContext context) async {
    RecipeEdit recipeProvider = Provider.of<RecipeEdit>(context, listen: false);
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
          throw new Exception('Oops! untuk nama kelompok bahan jangan lupa diisi ya !');
        }
        for(int z = 0; z < recipeProvider.ingredientsGroup[i].ingredients.length; z++) {
          TextEditingController ingredientsController = recipeProvider.ingredientsGroup[i].ingredients[z].textEditingController;
          if(ingredientsController.text == "") {
            FocusNode node = recipeProvider.ingredientsGroup[i].ingredients[z].focusNode;
            node.requestFocus();
            throw new Exception('Jangan lupa diisi bahan yang dibutuhkan ya !');
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
        TextEditingController controller = recipeProvider.steps[i].textEditingController;
        if(controller.text == "") {
          FocusNode node = recipeProvider.steps[i].focusNode;
          node.requestFocus();
          throw new Exception('Bagaimana cara memasaknya ?');
        }
        recipeProvider.stepsSendToHttp.add({
          "uuid": recipeProvider.steps[i].uuid,
          "item": controller.text
        });
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
      Object recipeId = ModalRoute.of(context).settings.arguments;
      await Provider.of<RecipeEdit>(context, listen: false).update(title, recipeId, ingredientsGroup, removeIngredientsGroup, ingredients, removeIngredients, steps, removeSteps, categoryName).then((value) {
        if(value["status"] == 200) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.SUCCES,
            animType: AnimType.RIGHSLIDE,
            headerAnimationLoop: false,
            dismissOnTouchOutside: false,
            title: 'Berhasil !',
            desc: 'Perubahan tersimpan !',
            btnOkOnPress: () => Navigator.of(context).popUntil((route) => route.isFirst),
            btnOkIcon: Icons.check,
            btnOkColor: Colors.blue.shade700
          )..show();
        } 
      });
    } on Exception catch(error) {
      String errorSplit = error.toString();
      List<String> errorText = errorSplit.split(":");
      SnackBar snackbar = SnackBar(
        backgroundColor: Colors.red[300],
        content: Text(errorText[1]),
        action: SnackBarAction(
          textColor: Colors.white,
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
    return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Batal Ubah?', style: TextStyle(color: Colors.black)),
        content: Text('Perubahan data tidak tersimpan apabila Anda keluar.'),
        actions: [
          FlatButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Tidak'),
          ),
          FlatButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Ya'),
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    Object recipeId = ModalRoute.of(context).settings.arguments;
    return Scaffold(
    appBar: AppBar(
      title: Text('Ubah Resep'),
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
            return Center(
              child: Text("Oops! Something went wrong! Please try again.")
            );
          }
          return SingleChildScrollView(
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
                          child: recipeProvider.fileImageRecipe == null ? CachedNetworkImage(
                          imageUrl: '$imagesRecipesUrl/${recipeProvider.getFileImageRecipe}',
                          imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator()
                        ),
                        errorWidget: (context, url, error) => Image.asset('assets/default-thumbnail.jpg'),
                        ) : Image.file(
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
              Container(
                margin: EdgeInsets.only(left: 18.0, top: 20.0, right: 18.0),
                child: Text(
                  'Kamu ingin buat masakan apa ?',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontStyle: FontStyle.italic
                  ),
                ),
              ),
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
              Container(
                margin: EdgeInsets.only(left: 18.0, top: 20.0, right: 18.0),
                child: Text(
                  'Kategori apa ?',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontStyle: FontStyle.italic
                  ),
                ),
              ),
            Container(
              margin: EdgeInsets.only(left: 18.0, top: 15.0, right: 18.0),
              child: Column(
                children: [
                  Consumer<RecipeEdit>(
                    builder: (context, value, child) => DropdownSearch(
                      mode: Mode.BOTTOM_SHEET,
                      showSelectedItem: true,
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
                  fontSize: 16.0,
                  fontStyle: FontStyle.italic
                ),
              ),
            ),
            Container(
              height: 220.0,
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
            Container(
              margin: EdgeInsets.only(left: 18.0, top: 20.0, right: 18.0),
              child: Text(
                'Apa saja bahan - bahan nya ?',
                style: TextStyle(
                  fontSize: 16.0,
                  fontStyle: FontStyle.italic
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
              child: textFormIngredientsEdit(context)
            ),
            Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              padding: EdgeInsets.all(10.0),
              width: double.infinity,
              child: Consumer<RecipeEdit>(
                builder: (context, recipeProvider, child) {
                  return RaisedButton(
                    child: Text(
                      'Tambah grup',
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
                    onPressed: () => recipeProvider.incrementIngredientsPerGroup()
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 18.0, top: 18.0, right: 18.0),
              child: Text(
                'Bagaimana Memasak nya ?',
                style: TextStyle(
                  fontSize: 16.0,
                  fontStyle: FontStyle.italic
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10.0),
              padding: EdgeInsets.all(10.0),
              width: double.infinity,
              child: textFormStepsEdited(context)
            ),
            Container(
              margin: EdgeInsets.all(10.0),
              padding: EdgeInsets.all(10.0),
              width: double.infinity,
              child: Consumer<RecipeEdit>(
                builder: (context, recipeProvider, child) {
                  return RaisedButton(
                    child: Text('Tambah langkah', 
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
                    onPressed: () => recipeProvider.incrementsSteps()
                  );
                }
              ),
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(10.0),
              padding: EdgeInsets.all(10.0),
                child: Consumer<RecipeEdit>(
                  builder: (context, recipeProvider, child) {
                    return Container(
                        height: 48.0,
                        child: recipeProvider.isLoading ? RaisedButton(
                          child: Center(
                            child: SizedBox(
                              child: CircularProgressIndicator(),
                            )
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(color: Colors.transparent)
                          ),
                          elevation: 0.0,
                          color: Colors.blue.shade700,
                          onPressed: null,
                        ) : RaisedButton(
                            child: Text(
                              'Simpan Perubahan',
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
                          onPressed: () => save(context),  
                        )
                      );
                    }
                  ),
                )
              ],
            )
          );
        },
      ),
    )
      );
  }
}