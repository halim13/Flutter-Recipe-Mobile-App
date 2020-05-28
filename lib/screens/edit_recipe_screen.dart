import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe.dart';

class EditRecipeScreen extends StatefulWidget {
  static const routeName = '/edit-recipe-screen';
  @override
  _EditRecipeScreenState createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  int ingredientsLength;
  int stepsLength;
  File _file;
  String idUpdate;
  String bodyUpdate;
  String title;
  String text;
  bool isInit = true;
  final GlobalKey<FormState> formTitleKey = GlobalKey();
  final GlobalKey<FormState> formIngredientsKey = GlobalKey();
  final GlobalKey<FormState> formStepsKey = GlobalKey();
  TextEditingController titleController = TextEditingController(); 
  List<TextEditingController> listIngredientsController = [TextEditingController()]; // must initial value first if not error
  List<TextEditingController> listStepsController = [TextEditingController()]; // must initial value first if not error
  List<Map<String, Object>> valueIngredientsController = [];
  List<Map<String, Object>> valueStepsController = [];
 
  @override 
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  } 

  void incrementIngredients() {
    setState(() {
      ingredientsLength++;
      listIngredientsController.add(TextEditingController());
    });
  }
  void incrementSteps() {
    setState(() {
      stepsLength++;
      listStepsController.add(TextEditingController());
    });
  }
  void decrementSteps(i) {
    setState(() {
      stepsLength--;
      valueStepsController.removeWhere((element) => element["id"] == i);
      listStepsController.removeWhere((element) => element == listStepsController[i]);
    });
  }
  void decrementIngredients(i) {
    setState(() {
      ingredientsLength--;
      valueIngredientsController.removeWhere((element) => element["id"] == i);
      listIngredientsController.removeWhere((element) => element == listIngredientsController[i]);
    });
  }

  void save() {
    formIngredientsKey.currentState.save();
    formStepsKey.currentState.save();
    formTitleKey.currentState.save();
    print(idUpdate);
    print(bodyUpdate);
    final seenSteps = Set();
    final seenIngredients = Set();
    final uniqueIngredients = valueIngredientsController.where((str) => seenIngredients.add(str["id"])).toList(); // Biar ngga duplicate
    final uniqueSteps = valueStepsController.where((str) => seenSteps.add(str["id"])).toList(); // Biar ngga duplicate
    final ingredients = jsonEncode(uniqueIngredients);
    final steps = jsonEncode(uniqueSteps);
    final mealId = ModalRoute.of(context).settings.arguments;
    // Provider.of<Recipe>(context, listen: false).update(title, mealId, _file, ingredients, steps, '054ba002-0122-496b-937e-32d05acef05c');
  } 

  @override 
  void didChangeDependencies() async {
    if(isInit) {
      final mealId = ModalRoute.of(context).settings.arguments;
      if(mealId != null) {
        await Provider.of<Recipe>(context, listen: false).edit(mealId);
        final provider = Provider.of<Recipe>(context, listen: false);
        ingredientsLength = provider.getIngredients.length;
        stepsLength = provider.getSteps.length;
        for (int i = 0; i < ingredientsLength; i++) {
          listIngredientsController[i].text = provider.getIngredients[i].body;
          valueIngredientsController.add({
            "id": i,
            "idclone": provider.getIngredients[i].id,
            "item": provider.getIngredients[i].body
          });
          listIngredientsController.add(TextEditingController());
        }
        for (int i = 0; i < stepsLength; i++) {
          listStepsController[i].text = provider.getSteps[i].body;
          listStepsController.add(TextEditingController());
        }
        titleController.text = provider.getRecipes.first.title;
      }
    }
    isInit = false;
    super.didChangeDependencies();
  }
  Widget build(BuildContext context) {
    const baseurl = 'http://192.168.43.226:5000/images/recipe/';
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
                      child: Image.network(
                        baseurl + provider.data.recipes.first.imageUrl,
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
                  key: formTitleKey,
                  child: Container(
                    width: 300,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    child: TextFormField(
                      controller: titleController,
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
                  child: textFormIngredients(provider)
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  width: 300,
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
                  width: 300,
                  child: textFormSteps(provider)
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  width: 300,
                  child: RaisedButton(
                    child: Text('Add Steps'),
                    onPressed: incrementSteps
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  width: 300,
                  child: RaisedButton(
                    child: Text('Save'),
                    onPressed: save,  
                  ),
                )
              ],
            )
          )
        );
      },
    );
  }

  Widget textFormIngredients(Recipe provider) {
    int itemStart = 1;
    return SingleChildScrollView(
      child: Form(
        key: formIngredientsKey,
        child: Column( 
          children: List.generate(ingredientsLength, (i) {
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
                    setState(() => bodyUpdate = value);
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

  Widget textFormSteps(provider) {
    int itemStart = 1;
    return SingleChildScrollView(
      child: Form(
        key: formStepsKey,
        child: Column( 
          children: List.generate(stepsLength, (i) {
            return Column(  
              children: [
                TextFormField(
                  controller: listStepsController[i],
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
                    final provider = Provider.of<Recipe>(context, listen: false);
                    valueStepsController.add({
                      "id": provider.getSteps[i].id,
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