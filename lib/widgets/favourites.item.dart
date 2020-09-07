import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../screens/profile/view.dart';
import '../constants/url.dart';

class FavoriteItem extends StatelessWidget {
  final String uuid;
  final String title;
  final String imageurl;
  final String portion;
  final String duration;
  final String categoryTitle;
  final String username;
  final String userId;
  final String countryName;

  FavoriteItem({
    this.uuid,
    this.title,
    this.imageurl,
    this.portion,
    this.duration,
    this.categoryTitle,
    this.username,
    this.userId,
    this.countryName
  });

  void detailRecipeFavorite(
    BuildContext context, 
    String uuid, 
    String title, 
    String userId,
  ) {
    Navigator.of(context).pushNamed(
      '/detail-recipe-favorite',
      arguments: {
        'uuid': uuid,
        'title': title,
        'userId': userId,  
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 4.0,
      margin: EdgeInsets.all(10.0),
      child: Column(
        children: [
          Stack(
            children: [
              InkWell(
                onTap: () {
                  detailRecipeFavorite(
                    context, 
                    uuid,
                    title, 
                    userId,
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: '$imagesRecipesUrl/$imageurl',
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
                  ),
                ),
              ),
              Positioned(
                bottom: 20.0,
                right: 10.0,
                child: Container(
                  width: 300.0,
                  color: Colors.black54,
                  padding: EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 20.0,
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 26.0,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule),
                    SizedBox(width: 6.0),
                    Text('${duration.toString()} min'),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.fastfood),
                    SizedBox(width: 6.0),
                    Text('$portion Portion'),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewProfileScreen(userId, username)),
              );
            },
            child: Container(
              padding: EdgeInsets.only(top: 0.0, left: 20.0, right: 20.0, bottom: 15.0),
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
                      ],
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
                              text: '$username',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0
                              ),
                            )
                          ]
                        ),
                      ),
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
          ),
        ],
      ),
    );
  }
}
