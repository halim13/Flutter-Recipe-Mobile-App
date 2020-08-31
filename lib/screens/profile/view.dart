import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../preview.image.dart';
import '../../constants/url.dart';
import '../../providers/user/user.dart';


class ViewProfileScreen extends StatefulWidget {
  ViewProfileScreen(this.userId, this.name);
  final String userId;
  final String name;
  static const routeName = '/review-profile';
  @override
  ViewProfileScreenState createState() => ViewProfileScreenState();
}

class ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: FutureBuilder(
        future: Provider.of<User>(context, listen: false).view(widget.userId),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator()
            );
          }
          if(snapshot.hasError) {
            return Consumer<User>(
              builder: (BuildContext context, User userProvider, Widget child) =>
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150.0,
                      child: Image.asset('assets/no-network.png')
                    ),
                    SizedBox(height: 15.0),
                    Text('Koneksi jaringan Anda buruk.',
                      style: TextStyle(
                        fontSize: 16.0
                      ),
                    ),
                    SizedBox(height: 10.0),
                    GestureDetector(
                      child: Text('Coba Ulangi',
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
              ),
            );
          }
          return Consumer<User>(
            builder: (BuildContext context, User userProvider, Widget child) {
              return ListView.builder(
              itemCount: userProvider.getViewProfileItem.length,
              itemBuilder: (context, i) {
                  return Column(
                    children: [
                      Stack(
                        overflow: Overflow.visible,
                        alignment: Alignment.center,
                        children: [
                          Image(
                            height: MediaQuery.of(context).size.height / 4,
                            fit: BoxFit.cover,
                            image: AssetImage('assets/default-thumbnail-profile.jpg')
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 80.0),
                            width: 120.0,
                            height: 120.0,
                            child: Column(
                              children: [
                                Stack(
                                  overflow: Overflow.visible,
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 120.0,
                                      height: 120.0,
                                      child: GestureDetector(
                                        child: ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl: '$imagesAvatarUrl/${userProvider.getViewProfileItem[i].avatar}',
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Image.asset('assets/default-avatar.png'),
                                            errorWidget: (context, url, error) => Image.asset('assets/default-avatar.png'),                                      
                                            fadeOutDuration: Duration(seconds: 1),
                                            fadeInDuration: Duration(seconds: 1),
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (_) {
                                            return PreviewImageScreen(
                                              url: imagesAvatarUrl,
                                              body: userProvider.getViewProfileItem[i].avatar
                                            );
                                          }));
                                        },
                                      ),
                                    ),
                                  ]
                                ),
                              ],
                            )
                          )
                        ],
                      ),
                      ListTile(
                        title: Text('Name'),
                        subtitle: Text(userProvider.getViewProfileItem[i].name)
                      ),
                      ListTile(
                        title: Text('E-mail Address'),
                        subtitle: Text(userProvider.getViewProfileItem[i].email)
                      ),
                      ListTile(
                        title: Text('Bio'),
                        subtitle: Text(userProvider.getViewProfileItem[i].bio)
                      ),                        
                    ],
                  );
                },
              );
            },
          );
        }
      ),
    );
  }
}

