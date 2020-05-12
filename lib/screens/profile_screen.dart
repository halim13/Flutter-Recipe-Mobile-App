import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import './login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
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
            : LoginScreen(),
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
              height: MediaQuery.of(context).size.height / 3,
              fit: BoxFit.cover,
              image: NetworkImage('https://img.freepik.com/free-vector/vegetables-banner-collection_1268-12420.jpg?size=626&ext=jpg'),
            ),
            Positioned(
              bottom: -50.0,
              width: 125,
              height: 125,
              child: CircleAvatar(
                radius: 80, 
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage('https://ramcotubular.com/wp-content/uploads/default-avatar.jpg'),
              )
            )
          ],
        ),
        SizedBox(height: 40),
        ListTile(
          title: Text('Name'),
          subtitle: Text(auth.userName),
        )
      ],
    );
  }
}