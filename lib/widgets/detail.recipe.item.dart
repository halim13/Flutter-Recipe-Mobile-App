import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../constants/url.dart';

import '../models/RecipeDetail.dart';
import '../helpers/preview.image.dart';

class DetailRecipeItem extends StatelessWidget {
  final String imageurl;
  final String title;
  final String duration;
  final String portion;
  final String countryName;
  final String userName;
  final String categoryTitle;

  final List<IngredientsGroupDetail> getIngredientsGroupDetail;
  final List<StepDetailData> getStepsDetail;

  DetailRecipeItem({
    this.imageurl,
    this.title,
    this.duration, 
    this.portion,
    this.countryName, 
    this.userName,
    this.categoryTitle,
    this.getIngredientsGroupDetail,
    this.getStepsDetail
  });

   Widget buildSectionTitle(BuildContext context, String text) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Text(text,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 17.0
        )
      ),
    );
  }

  Widget buildContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.all(10.0),
      width: double.infinity,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 300.0,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: '$imagesRecipesUrl/$imageurl',
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                )
              ),
              placeholder: (context, url) => Image.asset('assets/default-thumbnail.jpg'),
              errorWidget: (context, url, error) => Image.asset('assets/default-thumbnail.jpg'),
            ) 
          ),
          Container(
            margin: EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0, bottom: 5.0),
            padding: EdgeInsets.all(10.0),
            child: Text(
              '$title',
              style: TextStyle(
                fontSize: 19.0,
              ),
            )
          ), 
          Container(
            margin: EdgeInsets.only(left: 10.0, right: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule),
                    SizedBox(width: 6.0),
                    Text('$duration min'),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.fastfood),
                    SizedBox(width: 6.0),
                    Text('$portion Portion'),
                  ],
                )
              ],
            )
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [ 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.flag),
                        SizedBox(width: 6.0),
                        Text(countryName),
                      ]
                    ),
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Recipe by : ',
                            style: TextStyle(
                              color: Colors.black, 
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: '$userName',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0
                                ),
                              )
                            ]
                          ),
                        )
                      ]
                    )
                  ],
                ),
                SizedBox(height: 10.0),                          
                RichText(
                  text: TextSpan(
                    text: 'Category : ',
                    style: TextStyle(
                      color: Colors.black, 
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: '$categoryTitle',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0
                        ),
                      )
                    ]
                  ),
                )
              ]
            ),
          ),
          Center(
            child: buildSectionTitle(context, 'Ingredients')
          ),
          buildContainer(
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: getIngredientsGroupDetail.length,
              separatorBuilder: (context, index) {
                return Divider();
              },
              itemBuilder: (context, i) => Container(
                margin: EdgeInsets.only(bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('- ${getIngredientsGroupDetail[i].body}', 
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    SizedBox(height: 4.0),
                    ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: List.generate(getIngredientsGroupDetail[i].ingredients.length, (z) => Container(
                          child: Container(
                            margin: EdgeInsets.only(left: 10.0),
                            child: Text('- ${getIngredientsGroupDetail[i].ingredients[z].body}',
                              style: TextStyle(
                                fontSize: 16.0,
                                height: 1.75
                              ) 
                            )
                          )
                        )
                      )
                    ),
                  ],
                )
              )
            ),
          ),
          Center(
            child: buildSectionTitle(context, 'How to Cook')
          ),
          buildContainer(
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: getStepsDetail.length,
              separatorBuilder: (context, index) {
                return Divider();
              },
              itemBuilder: (context, i) => Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.shade700,
                      child: Text('${i + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        )
                      ),
                    ),
                    title: Text(
                      getStepsDetail[i].body,
                      style: TextStyle(
                        fontSize: 16.0,
                        height: 1.75
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(getStepsDetail[i].stepsImages.length, (z) => 
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) {
                            return PreviewImageScreen(
                              url: imagesStepsUrl,
                              body: getStepsDetail[i].stepsImages[z].body
                            );
                          })),
                          child: Container(
                            child: CachedNetworkImage(
                              width: 100.0,
                              height: 100.0,
                              imageUrl: '$imagesStepsUrl/${getStepsDetail[i].stepsImages[z].body}',
                              placeholder: (context, url) => Image.asset('assets/default-thumbnail.jpg'),
                              errorWidget: (context, url, error) => Image.asset('assets/default-thumbnail.jpg'),
                            )
                          ),
                        ),
                      )
                    ) 
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}