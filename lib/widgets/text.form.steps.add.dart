import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/recipe.add.dart';

Widget textFormStepsAdd(BuildContext context) {
  void pickImage(int i, int z) async {
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
        recipeProvider.stepsImage(i, z, pickedFile);
      }
    }
      return Consumer<RecipeAdd>(
        builder: (context, recipeProvider, child) {
          return Form(
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              controller: recipeProvider.stepsScrollController,
              itemCount: recipeProvider.steps.length,
              itemBuilder: (context, i) {
                return Container(
                  child: Column(
                    children: [
                      TextFormField(
                        maxLines: 3,
                        focusNode: recipeProvider.steps[i].focusNode,
                        controller: recipeProvider.steps[i].textEditingController,
                        style: TextStyle(
                          fontSize: 15.0
                        ),
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
                                  fontSize: 18.0,
                                )
                              )
                            ]
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: i > 0 ? Colors.grey : Colors.white,
                            ),
                            onPressed: i > 0 ? () => recipeProvider.decrementSteps(recipeProvider.steps[i].uuid) : null             
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
                        children: List.generate(recipeProvider.steps[i].images.length, (z) =>
                          Expanded(
                            child: Container(
                              width: 100.0,
                              height: 100.0,
                              margin: EdgeInsets.only(top: 15.0),
                              child: InkWell(
                                child: recipeProvider.steps[i].images[z].body,
                                onTap: () => pickImage(i, z)
                              ),
                            ),
                          )
                        )
                      )
                    ],
                  ),
                );
              }
            ),
          );
        }
      );
    }
    
