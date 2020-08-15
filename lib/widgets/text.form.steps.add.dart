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
          RecipeAdd recipe = Provider.of<RecipeAdd>(context, listen: false);
          PickedFile pickedFile = await ImagePicker().getImage(source: imageSource);
          recipe.stepsImage(i, z, pickedFile);
        }
      }
      return Consumer<RecipeAdd>(
        builder: (context, value, child) {
          return Form(
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              controller: value.stepsScrollController,
              itemCount: value.steps.length,
              itemBuilder: (context, i) {
                return Container(
                  child: Column(
                    children: [
                      TextFormField(
                        maxLines: 3,
                        focusNode: value.steps[i].focusNode,
                        controller: value.steps[i].textEditingController,
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
                            onPressed: i > 0 ? () => value.decrementSteps(value.steps[i].uuid) : null             
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
                        children: List.generate(value.steps[i].images.length, (z) =>
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(top: 15.0),
                              child: InkWell(
                                child: value.steps[i].images[z].body,
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
    
