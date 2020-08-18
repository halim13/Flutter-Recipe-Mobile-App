import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe.edit.dart';

Widget textFormIngredientsEdit(BuildContext context) {
  return Consumer<RecipeEdit>(
    builder: (context, recipeProvider, child) {
      return SingleChildScrollView(
        controller: recipeProvider.ingredientsScrollController,
          child: Form(
          child: ListView.builder( 
            shrinkWrap: true,
            itemCount: recipeProvider.ingredientsGroup.length,
            itemBuilder: (context, i) {
              return Container(
                child: Column(
                  children: [
                    Row(
                      children: [ 
                        IconButton(
                          icon: Icon(
                            Icons.more_vert,
                            color: Colors.grey,
                          ),
                          onPressed: null,
                        ),
                        Flexible(
                          child: TextFormField(
                            style: TextStyle(
                              fontSize: 15.0
                            ),
                              focusNode: recipeProvider.ingredientsGroup[i].focusNode,
                              controller: recipeProvider.ingredientsGroup[i].textEditingController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                
                                hintStyle: TextStyle(
                                  fontSize: 15.0
                                ),
                                hintText: "Mis: 1 kg sapi",
                              ),
                            ),
                          ),
                          IconButton(
                            color: Colors.brown[300],
                            icon: Icon(
                              Icons.add_circle_outline,
                            ),
                            onPressed: () {
                              recipeProvider.incrementIngredients(i);
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: i > 0 ? Colors.grey : Colors.transparent,
                            ),
                            onPressed: () => i > 0 ? recipeProvider.decrementIngredientsPerGroup(recipeProvider.ingredientsGroup[i].uuid) : null
                          ),
                        ]
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: recipeProvider.ingredientsGroup[i].ingredients.length,
                        itemBuilder: (context, z) {
                          return Row(
                            children: [
                              SizedBox(width: 20.0),
                              Text('${z + 1}.', style: TextStyle(
                                fontSize: 18.0
                                )
                              ),
                              SizedBox(width: 15.0),
                              Flexible(
                                child: TextFormField(         
                                  focusNode: recipeProvider.ingredientsGroup[i].ingredients[z].focusNode,
                                  controller: recipeProvider.ingredientsGroup[i].ingredients[z].textEditingController,
                                  decoration: InputDecoration(
                                    hintText: 'Mis: 1 kg sapi',
                                  ),
                                )
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: z > 0 ? Colors.grey : Colors.transparent
                                ),
                                onPressed: () => z > 0 ? recipeProvider.decrementIngredients(i, recipeProvider.ingredientsGroup[i].ingredients[z].uuid) : null
                              )
                            ],
                          );
                        }, 
                      )
                    ]
                  ),
                );
              },
            )
          )
        );
      }
    );
  }