import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../screens/favorite/detail.favorite.dart';
import '../constants/url.dart';

class RecipeItem extends StatelessWidget {
  final int id;
  final String uuid;
  final String title;
  final String imageUrl;
  final String portion;
  final String duration;
  final String name;

  RecipeItem({
    this.id,
    this.uuid,
    this.title,
    this.imageUrl,
    this.portion,
    this.duration,
    this.name
  });

  void selectRecipe(context) {
    Navigator.of(context).pushNamed(
      RecipeDetailFavoriteScreen.routeName,
      arguments: {
        "uuid": uuid, 
        "title": title
      },
    );
  }  

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => selectRecipe(context),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 4.0,
        margin: EdgeInsets.all(10.0),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: '$imagesRecipesUrl/$imageUrl',
                    imageBuilder: (context, imageProvider) => Container(
                      width: double.infinity,
                      height: 250.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      )
                    ),
                    placeholder: (context, url) => Image.asset('assets/default-thumbnail.jpg'),
                    errorWidget: (context, url, error) => Image.asset('assets/default-thumbnail.jpg'),
                    fadeOutDuration: Duration(seconds: 1),
                    fadeInDuration: Duration(seconds: 1),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 10,
                  child: Container(
                    width: 300,
                    color: Colors.black54,
                    padding: EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 20,
                    ),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                )
              ],
            ),
            Container(
              padding: EdgeInsets.all(20.0),
              height: 80.0,
              child: Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule),
                        SizedBox(width: 6),
                        Text('${duration.toString()} min'),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.fastfood),
                        SizedBox(width: 6),
                        Text(portion),
                      ],
                    ),
                    // Row(
                    //   children: [
                    //     Icon(Icons.people),
                    //     SizedBox(width: 6),
                    //     Text('Dibuat oleh $name'),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
