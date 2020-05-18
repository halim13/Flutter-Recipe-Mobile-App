import 'dart:io';


// import 'package:path/path.dart' as path; // gunakan as path agar tidak terjadi bentrok
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_cropper/image_cropper.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../providers/user.dart';
import './login_screen.dart';
import './register_screen.dart';


class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {

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
      File file = await ImagePicker.pickImage(source: imageSource);
      if (file != null) {
        final user = Provider.of<User>(context, listen: false);
        // setState(() => _file = file); cara penulisan singkat setState
        user.file = file;
        File cropped = await ImageCropper.cropImage(
          sourcePath: user.file.path,
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
        user.file = cropped ?? user.file;
        user.toggleSaveChanges();
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
        return Consumer<User>(
          builder: (context, user, child) {
              return RefreshIndicator(
                  onRefresh: () => user.refreshProfile(),
                  child: ListView.builder(
                  itemCount: user.items.length,
                  itemBuilder: (context, index) {
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
                            // image: NetworkImage('https://img.freepik.com/free-vector/vegetables-banner-collection_1268-12420.jpg?size=626&ext=jpg'),
                          ),
                          Positioned(
                            bottom: -50.0,
                            width: 125,
                            height: 125,
                            child: InkWell(
                              onTap: pickImage,
                              child: ClipRRect(
                              borderRadius: BorderRadius.circular(80),
                              child: user.file == null
                              ? CachedNetworkImage(
                                  imageUrl: 'http://192.168.43.85:5000/images/avatar/${user.items[index].avatar}',
                                  imageBuilder: (context, imageProvider) => Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(80),
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover
                                      )
                                    ),
                                  ),
                                  fadeInDuration: const Duration(milliseconds: 3000),
                                  placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(80),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: AssetImage('assets/default-avatar.png')
                                      )
                                    ),
                                  ),
                                )       
                              : FadeInImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(user.file),
                                  placeholder: AssetImage("assets/default-avatar.png")
                                ),
                              )
                              // CircleAvatar(
                              //   radius: 80, 
                              //   backgroundColor: Colors.white,
                              //   backgroundImage: NetworkImage(),
                              // ),
                              // child: ClipRRect(
                              //   borderRadius: BorderRadius.circular(80),
                              //   child: FadeInImage(
                              //     fit: BoxFit.cover,
                              //     image: _file == null ? auth.userAvatar != "" ? NetworkImage("http://192.168.43.85:5000/images/avatar/${auth.userAvatar}") : FileImage(File(_avatar)) : FileImage(File(user.userAvatar)),
                              //     placeholder: AssetImage("assets/default-avatar.png")
                              //   ),
                              // ),
                            )
                          )
                        ],
                      ),
                      SizedBox(height: 40),
                      ListTile(
                        title: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Name'),
                              Consumer<User>(
                                builder: (context, user, child) {
                                return IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => user.toggleFormEditUsername()
                                );
                                }
                              )  
                            ],
                          )
                        ),
                        subtitle: 
                          Consumer<User>(
                            builder: (context, user, child) {
                              return user.isToggleFormEditUsername()
                              ?
                                Form(
                                  child: TextFormField(
                                    initialValue: user.items[index].name,
                                  ),
                                )
                              : Text(
                                  user.items[index].name
                                );
                            }
                          )
                      ),
                      ListTile(
                        title: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('E-mail Address'),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => user.toggleFormEditEmail(),
                              )   
                            ],
                          )
                        ),
                        subtitle: 
                        user.isToggleFormEditEmail()
                        ? Form(
                            child: TextFormField(
                              initialValue: user.items[index].email,
                            ),
                          )
                        : Text(user.items[index].email)
                      ),
                      SizedBox(height: 30),
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
                              onPressed: () {
                                Provider.of<User>(context, listen: false).update(user.file);
                              },
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
}