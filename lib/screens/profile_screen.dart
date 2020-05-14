import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import './login_screen.dart';
import './register_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  File _file;

  void pickImage() async { 
    final imageSource = await showDialog<ImageSource>(context: context, builder: (context) => 
      AlertDialog(
        title: Text(
          "Pilih sumber gambar",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold, 
        ),
      ),
      actions: <Widget>[
        MaterialButton(
          child: Text(
            "Camera",
            style: TextStyle(color: Colors.blueAccent),
          ),
          onPressed: () => Navigator.pop(context, ImageSource.camera),
        ),
        MaterialButton(
          child: Text(
            "Gallery",
            style: TextStyle(color: Colors.blueAccent),
          ),
          onPressed: () => Navigator.pop(context, ImageSource.gallery),
        )
      ],
    ));
    if (imageSource != null) {
      final file = await ImagePicker.pickImage(source: imageSource);
      if (file != null) {
        setState(() => _file = file);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<Auth>(
      builder: (context, auth, child) {
        if(auth.isAuth) {
          return buildProfile(auth);
        } else {
          return FutureBuilder(
            future: auth.tryAutoLogin(),
            builder: (ctx, snapshot) =>
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

  Widget buildProfile(Auth auth) {
    return Column(
      children: [
        Stack(
          overflow: Overflow.visible,
          alignment: Alignment.center,
          children: [
            Image(
              height: MediaQuery.of(context).size.height / 4,
              fit: BoxFit.cover,
              image: NetworkImage('https://img.freepik.com/free-vector/vegetables-banner-collection_1268-12420.jpg?size=626&ext=jpg'),
            ),
            Positioned(
              bottom: -50.0,
              width: 125,
              height: 125,
              child: InkWell(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 80, 
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage('https://ramcotubular.com/wp-content/uploads/default-avatar.jpg'),
                ),
              )
            )
          ],
        ),
        SizedBox(height: 40),
        ListTile(
          title: Text('Name'),
          subtitle: Text(auth.userName),
        ),
        ListTile(
          title: Text('E-mail Address'),
          subtitle: Text(auth.userEmail),
        )
      ],
    );
  }
}