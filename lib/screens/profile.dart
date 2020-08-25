// import 'package:path/path.dart' as path; // gunakan as path agar tidak terjadi bentrok

import 'package:flutter_complete_guide/constants/url.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/preview.image.dart';
import '../providers/auth.dart';
import '../providers/user.dart';
import './login.dart';
import './register.dart';


class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
 
  
  @override
  Widget build(BuildContext context) {
    return Consumer<Auth>(
      builder: (context, auth, child) {
        if(auth.isAuth) {
          return buildProfile();
        } else {
          return FutureBuilder(
            future: auth.tryAutoLogin(),
            builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator()
              )
            : Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF73AEF5),
                      Color(0xFF61A4F1),
                      Color(0xFF478DE0),
                      Color(0xFF398AE5),
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RaisedButton(
                      elevation: 2.0,
                      onPressed: () {
                        Navigator.of(context).pushNamed(LoginScreen.routeName);
                      },
                      padding: EdgeInsets.all(15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      color: Colors.white,
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          letterSpacing: 1.5,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    SizedBox(height: 12.0),
                    RaisedButton(
                      elevation: 2.0,
                      onPressed: () {
                        Navigator.of(context).pushNamed(RegisterScreen.routeName);
                      },
                      padding: EdgeInsets.all(15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      color: Colors.white,
                      child: Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          letterSpacing: 1.5,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ]
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget buildProfile() {
    return FutureBuilder(
      future:  Provider.of<User>(context, listen: false).getCurrentProfile(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator()
          );
        }
        if(snapshot.hasError) {
          return Consumer<User>(
            builder: (context, userProvider, child) =>
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
          builder: (context, user, child) {
            return RefreshIndicator(
              onRefresh: () => user.refreshProfile(),
              child: ListView.builder(
              itemCount: user.items.length,
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
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: GestureDetector(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(120.0),
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Image.asset('assets/default-thumbnail.jpg'),
                                            errorWidget: (context, url, error) => Image.asset('assets/default-thumbnail.jpg'),                                          
                                            imageUrl: '$imagesAvatarUrl/${user.items[i].avatar}',
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (_) {
                                            return PreviewImageScreen(
                                              url: imagesAvatarUrl,
                                              body: user.items[i].avatar
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
                        title: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Name'),
                            ],
                          )
                        ),
                        subtitle: Consumer<User>(
                          builder: (context, user, child) {
                            return Text(
                              user.items[i].name.toString()
                            );
                          }
                        )
                      ),
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('E-mail Address'),
                          ],
                        ),
                        subtitle: Text(user.items[i].email)
                      ),
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Bio'),
                          ],
                        ),
                        subtitle: Text(user.items[i].bio)
                      ),                        
                    ],
                  );
                },
              ),
            );
          },
        );
      }
    );
  }
  Widget currentAvatar(User user, int i) {
    return Container(
      width: 120.0,
      height: 120.0,
      child: CachedNetworkImage(progressIndicatorBuilder: (context, url, progress) =>
        CircularProgressIndicator(
          value: progress.progress,
        ),
        imageUrl: '$imagesAvatarUrl/${user.items[i].avatar}',
      ),
    );
  }
  // Widget previewAvatar(User user) {
  //   return FadeInImage(
  //     width: 120.0,
  //     height: 120.0,
  //     fit: BoxFit.cover,
  //     image: FileImage(user.file),
  //     placeholder: AssetImage("assets/default-avatar.png")
  //   );
  // }
}

