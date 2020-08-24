// import 'package:path/path.dart' as path; // gunakan as path agar tidak terjadi bentrok
// import 'package:transparent_image/transparent_image.dart';
import 'dart:io';

import 'package:flutter_complete_guide/constants/url.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
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
  final GlobalKey<FormState> formUsernameKey = GlobalKey();
  final GlobalKey<FormState> formBioKey = GlobalKey();
  final usernameController = TextEditingController();
  final bioController = TextEditingController();
  Future save() async {
    try {
      if (usernameController.text.isEmpty || usernameController.text.length < 3) {
        throw ErrorDescription("Username is too short. Minimum 3 characters.");
      }
      await Provider.of<User>(context, listen: false).update(
        usernameController.text, 
        bioController.text
      );
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Succesfully updated data.'),
          duration: Duration(seconds: 2)
        ),
      );
    } on ErrorDescription catch(error) {
      Fluttertoast.showToast(
        msg: error.toString(),
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white
      );
    }
  }

  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  void pickImage() async { 
    ImageSource imageSource = await showDialog<ImageSource>(context: context, builder: (context) => 
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
      File _file = File(await ImagePicker().getImage(source: imageSource).then((pickedFile) => pickedFile.path));
      if (_file != null) {
        User userProvider = Provider.of<User>(context, listen: false);
        userProvider.file = _file;
        userProvider.filename = _file.path;
        File cropped = await ImageCropper.cropImage(
          sourcePath: userProvider.filename,
          androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Crop It',
          toolbarColor: Colors.blueGrey[900],
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          )
        );
        if(cropped != null) {
          _file = cropped;
          userProvider.file = cropped;
        }
        userProvider.toggleSaveChanges();
        // userProvider.file = cropped ?? userProvider.file;
        // setState(() =>  _file = cropped ?? _file);
      }
    }
  }
  
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
              usernameController.text = user.items[i].name;
              bioController.text = user.items[i].bio;
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
                                          borderRadius: BorderRadius.circular(150.0),
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => CircularProgressIndicator(),                                          
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
                        subtitle: Text(user.items[i].email.toString())
                      ),
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Bio'),
                          ],
                        ),
                        subtitle: Text(user.items[i].bio.toString())
                      ),
                      if(user.isToggleSavedChanges()) 
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            RaisedButton(
                              padding: EdgeInsets.all(15.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              textColor: Colors.white,
                              color: Color(0xFF478DE0),
                              child: Text('Cancel'),
                              onPressed: () => user.isCancelEditUser(),
                            ),
                            RaisedButton(
                              padding: EdgeInsets.all(15.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              textColor: Colors.white,
                              color: Color(0xFF478DE0),
                              child: Text('Save Changes'),
                              onPressed: save
                            ),
                          ],
                        )
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
  Widget previewAvatar(User user) {
    return FadeInImage(
      width: 120.0,
      height: 120.0,
      fit: BoxFit.cover,
      image: FileImage(user.file),
      placeholder: AssetImage("assets/default-avatar.png")
    );
  }
}

