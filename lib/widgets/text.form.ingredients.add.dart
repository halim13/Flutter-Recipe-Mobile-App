import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe.add.dart';

Widget textFormIngredientsAdd() {
  return Consumer<RecipeAdd>(
    builder: (context, value, child) {
      return SingleChildScrollView(
        controller: value.ingredientsScrollController,
        child: Form(
          key: value.formIngredientsKey,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: value.ingredientsGroup.length,
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
                            focusNode: value.focusIngredientPerGroupNode[i]["item"],
                            controller: value.controllerIngredientPerGroup[i]["item"],
                            decoration: InputDecoration(
                              border: InputBorder.none,   
                              hintStyle: TextStyle(
                                fontSize: 15.0
                              ),
                              hintText: "Mis: Bahan utama",
                            ),
                          ),
                        ),
                        RaisedButton(
                          elevation: 0.0,
                          color: Colors.brown[300],
                          child: Text('Tambah bahan', style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0
                            )
                          ),
                          onPressed: () {
                            value.incrementIngredients(i);
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: i > 0 ? Colors.grey : Colors.transparent,
                          ),
                          onPressed: () => i > 0 ? value.decrementIngredientPerGroup(value.ingredientsGroup[i].uuid) : null
                        ),
                      ],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: value.ingredientsGroup[i].ingredients.length,
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
                                focusNode: value.focusIngredientsNode[z]["item"],
                                controller: value.controllerIngredients[z]["item"],
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
                              onPressed: () => z > 0 ? value.decrementIngredients(i, value.ingredientsGroup[i].ingredients[z].uuid) : null
                            )
                          ],
                        );
                      }, 
                    )
                  ]
                ),
              );
              }
            )
          ),
        );
    }
  );
}