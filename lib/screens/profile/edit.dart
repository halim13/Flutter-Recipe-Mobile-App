import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import '../../constants/url.dart';
import '../../providers/user/user.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String name;
  String email;
  String bio;
  File f;
  bool isUploading = false;
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

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
      actions: [
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
        setState(() {
          f = _file;
        });
        File cropped = await ImageCropper.cropImage(
          sourcePath: f.path,
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
          setState(() {
            f = cropped;
          });
        } else {
          setState(() {
            f = null;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    void save() async {
      FormState form = formKey.currentState;
      if(form.validate()) {
        form.save();
        final response = await Provider.of<User>(context, listen: false).update(f, name, bio);
        if(response["status"] == 200) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.SUCCES,
            animType: AnimType.BOTTOMSLIDE,
            headerAnimationLoop: false,
            dismissOnTouchOutside: false,
            title: 'Berhasil ',
            desc: 'Perubahan tersimpan',
            btnOkOnPress: () => Navigator.of(context).popUntil((route) => route.isFirst),
            btnOkIcon: null,
            btnOkColor: Colors.blue.shade700
          )..show();
      }
    }
  }
    return Scaffold(
      appBar: AppBar(
        title: Text('Ubah Profil'),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back
          ),
          onPressed: () => Navigator.pop(context, true),
        )
      ),
      body: FutureBuilder(
        future: Provider.of<User>(context, listen: false).getCurrentProfile(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
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
            builder: (BuildContext context, User userProvider, Widget child) {
            return ListView.builder(
                itemCount: userProvider.getCurrentProfileItem.length,
                itemBuilder: (context, i) {
                return Form(
                    key: formKey,
                    child: Container(
                      margin: EdgeInsets.all(10.0),
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              Center(
                                child: Container(
                                  width: 120.0,
                                  height: 120.0,
                                  margin: EdgeInsets.only(bottom: 15.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(120),
                                    child: f == null 
                                    ? CachedNetworkImage(
                                        imageUrl: '$imagesAvatarUrl/${userProvider.getCurrentProfileItem[i].avatar}',
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Image.asset("assets/default-avatar.png"),
                                        errorWidget: (context, url, error) => Image.asset("assets/default-avatar.png"),
                                        fadeOutDuration: Duration(seconds: 1),
                                        fadeInDuration: Duration(seconds: 1),
                                      )
                                    : FadeInImage(
                                      fit: BoxFit.cover,
                                      image: FileImage(f),
                                      placeholder: AssetImage("assets/default-avatar.png")
                                    )
                                  ),
                                )
                              ),
                              Center(
                                child: Container(
                                  width: 120.0,
                                  height: 120.0,
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: GestureDetector(
                                          onTap: () {
                                            pickImage();
                                          },
                                          child: Container(
                                            height: 50.0,
                                            width: 50.0,
                                            decoration: BoxDecoration(   
                                              color: Colors.blue.shade700,
                                              borderRadius: BorderRadius.circular(50.0)
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.photo_camera,
                                                  color: Colors.white,
                                                )
                                              ],
                                            ),
                                          )
                                        )
                                      )
                                    ],
                                  )
                                )
                              )
                            ]
                          ),
                          TextFormField(
                            initialValue: userProvider.getCurrentProfileItem[i].name,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: "Name",
                              labelStyle: TextStyle(
                                color: Colors.grey
                              ),
                              hintText: "Name",
                              fillColor: Colors.white,
                              filled: true,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                borderSide: BorderSide(color: Colors.grey)
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: BorderSide(),
                              ),
                            ),
                            onSaved: (val) {
                              name = val;
                            },
                            validator: (val) {
                              if(val.length < 1) {
                                return 'Namanya tidak boleh kosong';
                              }
                              return null;
                            },
                            style: TextStyle(
                              fontSize: 16.0
                            ),
                          ),
                          SizedBox(height: 9.0),
                          TextFormField(
                            initialValue:  userProvider.getCurrentProfileItem[i].email,
                            keyboardType: TextInputType.emailAddress,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: "E-mail Address",
                              labelStyle: TextStyle(
                                color: Colors.grey
                              ),
                              hintText: "E-mail Address",
                              fillColor: Colors.white,
                              filled: true,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                borderSide: BorderSide(color: Colors.grey)
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: BorderSide(),
                              ),
                            ),
                            onSaved: (val) {
                              email = val;
                            },
                            validator: (val) {
                              if(val.length < 1) {
                                return 'Email tidak boleh kosong.';
                              }
                              if(!val.contains('@')) {
                                return 'Format Email salah.';
                              }
                              return null;
                            },
                            style: TextStyle(
                              fontSize: 16.0
                            ),
                          ),
                          SizedBox(height: 9.0),
                          TextFormField(
                            initialValue: userProvider.getCurrentProfileItem[i].bio,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: "Bio",
                              labelStyle: TextStyle(
                                color: Colors.grey
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              hintText: "Bio",
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                borderSide: BorderSide(color: Colors.grey)
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: BorderSide(),
                              ),
                            ),
                            maxLines: 6,
                            onSaved: (val) {
                              bio = val;
                            },
                            validator: (val) {
                              if(val.length < 1) {
                                return 'Bio tidak boleh kosong.';
                              }
                              return null;
                            },
                            style: TextStyle(
                              fontSize: 16.0
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Container(
                            width: double.infinity,
                            height: 45.0,
                            child: Consumer<User>(
                              builder: (context, userProvider, child) {
                                return RaisedButton(
                                  child: userProvider.isLoading 
                                  ? Center(
                                      child: SizedBox(
                                        width: 30.0,
                                        height: 30.0,
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    )
                                  : Text(
                                      'Simpan Perubahan', 
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0
                                      )
                                    ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    side: BorderSide(color: Colors.transparent)
                                  ),
                                  color: Colors.blue.shade700,
                                  elevation: 0.0,
                                  onPressed: () => save(),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }
              );
            }
          );
        }
      )
    );
  }
}