import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe.add.dart';

Widget textFormStepsAdd() {
  return Consumer<RecipeAdd>(
    builder: (context, value, child) {
      return Form(
        key: value.formStepsKey,
        child: ListView.builder(
          shrinkWrap: true,
          controller: value.stepsScrollController,
          itemCount: value.startSteps,
          itemBuilder: (context, i) {
            return Container(
              margin: EdgeInsets.only(top: 20.0),
              child: Column(
                children: [
                  TextFormField(
                    maxLines: 2,
                    focusNode: value.focusStepsNode[i]["item"],
                    controller: value.controllerSteps[i]["item"],
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
                              fontSize: 19.0,
                            )
                          )
                        ],
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: i > 0 ? Colors.grey : Colors.white,
                        ),
                        onPressed: () {
                          if(i > 0) {
                          
                          }
                        },
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
                          margin: EdgeInsets.only(top: 10.0),
                          height: 100.0,
                          child: InkWell( 
                            child: value.steps[i].images[z].body,                                                   
                            onTap: null
                          ),
                        )
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