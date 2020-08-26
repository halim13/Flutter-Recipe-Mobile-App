import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/screens/detail.favorite.dart';
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
        elevation: 4,
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
                  child: Image.network(
                    '$imagesRecipesUrl/$imageUrl',
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
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
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                  Row(
                    children: [
                      Icon(Icons.people),
                      SizedBox(width: 6),
                      Text('Dibuat oleh $name'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
