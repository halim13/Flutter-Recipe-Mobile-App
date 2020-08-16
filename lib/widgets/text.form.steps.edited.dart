import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/recipe.edit.dart';

Widget textFormStepsEdited(BuildContext context) {
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
      RecipeEdit recipe = Provider.of<RecipeEdit>(context, listen: false);
      PickedFile pickedFile = await ImagePicker().getImage(source: imageSource);
      recipe.stepsImage(i, z, pickedFile);
    }
  }
  return Consumer<RecipeEdit>(
    builder: (context, recipe, child) {
      return Form(
        child: ListView.builder(
            shrinkWrap: true,
            controller: recipe.stepsScrollController,
            itemCount: recipe.steps.length,
            itemBuilder: (context, i) {
              return Container(
                margin: EdgeInsets.only(top: 20.0),
                child: Column(  
                children: [
                  TextFormField(
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: 15.0
                    ),
                    focusNode: recipe.steps[i].focusNode,
                    controller: recipe.steps[i].textEditingController,
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
                        onPressed: i > 0 ? () => recipe.decrementSteps(recipe.steps[i].uuid) : null             
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
                          margin: EdgeInsets.only(top: 15.0),
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
        );
      }
    );
  }