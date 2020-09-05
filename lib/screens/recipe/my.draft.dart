import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quartet/quartet.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../constants/url.dart';
import '../../providers/recipe/my.draft.dart';
import '../../screens/profile/view.dart';

class MyDraftScreen extends StatefulWidget {
  @override
  _MyDraftScreenState createState() => _MyDraftScreenState();
}

class _MyDraftScreenState extends State<MyDraftScreen> {
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        Provider.of<MyDraft>(context, listen: false).getRecipesDraft(5);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void selectRecipe(
    BuildContext context, 
    String uuid, 
    String title,
    String userId
  ) {
    Navigator.of(context).pushNamed(
      '/detail-recipe',
      arguments: {
        'uuid': uuid,
        'title': title,
        'userId': userId
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Drafts')
      ),
      body: FutureBuilder(
        future: Provider.of<MyDraft>(context, listen: false).getRecipesDraft(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if(snapshot.hasError) {
            return  Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150.0,
                      child: Image.asset('assets/no-network.png')
                    ),
                    SizedBox(height: 15.0),
                    Text('Bad Connection or Server Unreachable',
                      style: TextStyle(
                        fontSize: 16.0
                      ),
                    ),
                    SizedBox(height: 10.0),
                    GestureDetector(
                      child: Text('Try Again',
                        style: TextStyle(
                          fontSize: 16.0,
                          decoration: TextDecoration.underline
                        ),
                      ),
                      onTap: () {
                        setState((){});
                      },
                    ),
                  ],
                ),
              );
          }
          return Consumer<MyDraft>(
            child: Center(
              child: Text('There is no Drafts yet'),
            ),
            builder: (BuildContext context, MyDraft recipeProvider, Widget child) => recipeProvider.getRecipesDraftItem.length <= 0 ? child :
            RefreshIndicator(
              onRefresh: () => recipeProvider.refreshRecipesDraft(),
              child: ListView.builder(
              controller: controller,
              itemCount: recipeProvider.getRecipesDraftItem.length,
              itemBuilder: (context, i) {
                if(i == recipeProvider.getRecipesDraftItem.length) 
                  return CircularProgressIndicator();
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)
                    ),
                    elevation: 4.0,
                    margin: EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            InkWell(
                              onTap: () {
                                selectRecipe(
                                  context, 
                                  recipeProvider.getRecipesDraftItem[i].uuid,
                                  recipeProvider.getRecipesDraftItem[i].title, 
                                  recipeProvider.getRecipesDraftItem[i].user.uuid
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15.0),
                                  topRight: Radius.circular(15.0),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: '$imagesRecipesUrl/${recipeProvider.getRecipesDraftItem[i].imageurl}',
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
                                  titleCase(recipeProvider.getRecipesDraftItem[i].title),
                                  style: TextStyle(
                                    fontSize: 26.0,
                                    color: Colors.white,
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ),
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
                                  Text('${recipeProvider.getRecipesDraftItem[i].duration} min'),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.fastfood),
                                  SizedBox(width: 6.0),
                                  Text('${recipeProvider.getRecipesDraftItem[i].portion} Portion'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ViewProfileScreen(recipeProvider.getRecipesDraftItem[i].user.uuid, recipeProvider.getRecipesDraftItem[i].user.name)),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.only(top: 0.0, left: 20.0, right: 20.0, bottom: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.flag),
                                    SizedBox(width: 6.0),
                                    Text(recipeProvider.getRecipesDraftItem[i].country.name),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.people),
                                    SizedBox(width: 6.0),
                                    RichText(
                                      text: TextSpan(
                                        text: 'Recipe by : ',
                                        style: TextStyle(
                                          color: Colors.black, 
                                          fontSize: 16.0
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: '${recipeProvider.getRecipesDraftItem[i].user.name}',
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
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              ),
            )
          );
        }
      )
    );
  }
}