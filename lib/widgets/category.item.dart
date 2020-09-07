import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CategoryItem extends StatelessWidget {
  final String uuid;
  final String title;
  final String cover;

  CategoryItem({
    this.uuid,
    this.title,
    this.cover
  });

  void showRecipe(BuildContext context, String uuid, String title) {
    Navigator.of(context).pushNamed('/show-recipe',
      arguments: {
        'uuid': uuid,
        'title': title,
      },
   );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showRecipe(context, uuid, title);
      },
      borderRadius: BorderRadius.circular(15.0),
      child: CachedNetworkImage(
        imageUrl: '$cover',
        imageBuilder: (context, imageProvider) => Container(
          child: Container(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(6.0),
                  color: Colors.black26,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
              ],
            ),
          ),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider, 
              fit: BoxFit.cover
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        placeholder: (context, url) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/default-thumbnail.jpg'), 
              fit: BoxFit.cover
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/default-thumbnail.jpg'), 
              fit: BoxFit.cover
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
      )
    );
  }
}