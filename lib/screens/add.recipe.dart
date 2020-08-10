import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/text.form.ingredients.add.dart';
import '../widgets/text.form.steps.add.dart';
import '../providers/recipe.add.dart';
import '../models/Category.dart';

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
  void save(BuildContext context) async {
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
      await Provider.of<RecipeAdd>(context, listen: false).store(title, ingredients, steps, selectedCategory.uuid, _file);
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
        title: Text('Buat Resep'),
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
              return Form(
                key: value.formTitleKey,
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
                    onSaved: (val) {
                      value.titleController.text = val;
                    },
                  )
                ),
              );
            }
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
          // Container(
          //   margin: EdgeInsets.only(left: 10.0, right: 10.0),
          //   padding: EdgeInsets.all(10.0),
          //   width: double.infinity,
          //   child: RaisedButton(
          //     elevation: 0.0,
          //     color: Colors.brown[300],
          //     child: Text(
          //       'Tambah bahan',
          //       style: TextStyle(
          //         color: Colors.white,
          //         fontSize: 14.0
          //       ),
          //     ),
          //     onPressed: incrementIngredients
          //   ),
          // ),
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
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            width: double.infinity,
            child: textFormStepsAdd()
          ),
          Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            width: double.infinity,
            child: RaisedButton(
              elevation: 0.0,
              color: Colors.brown[300],
              child: Text('Tambah langkah', 
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0
                ),  
              ),
              onPressed: incrementSteps
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
