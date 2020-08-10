import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe.edit.dart';

Widget textFormIngredientsEdit(BuildContext context) {
  return Consumer<RecipeEdit>(
    builder: (context, value, child) {
      return SingleChildScrollView(
          controller: value.ingredientsScrollController,
          child: Form(
          key: value.formIngredientsKey,
          child: ListView.builder( 
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: value.ingredients.length,
            itemBuilder: (context, i) {
              return TextFormField(
                style: TextStyle(
                  fontSize: 15.0
                ),
                  focusNode: value.focusIngredientsNode[i]["item"],
                  controller: value.controllerIngredients[i]["item"],
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: i > 0 ? Colors.grey : Colors.transparent,
                      ),
                      onPressed: () { 
                        if(i > 0) {
                          value.decrementIngredients(value.ingredients[i].uuid);
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
                );
              },
            )
          )
        );
      }
    );
  }