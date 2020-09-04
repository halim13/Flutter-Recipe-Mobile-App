import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../providers/auth/auth.dart';
import './login.dart';
import '../tabs/tabs.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';
  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final nameController = TextEditingController();
  final emailController  = TextEditingController();
  final passwordController = TextEditingController();
  String name;
  String email;
  String password;
  bool loading = false; 
  bool obscure = true;

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void register(context) async {
    // if (!formKey.currentState.validate()) {
    //   return;
    // }
    try {
      if(nameController.text.isEmpty || nameController.text.length < 1) {
        throw new Exception('Name is required');
      }
      if(emailController.text.isEmpty || !emailController.text.contains('@')) {
        throw new Exception('Invalid Email. \n Eg (johndoe@gmail.com)');
      }
      if(passwordController.text.isEmpty || passwordController.text.length < 6) {
        throw new Exception('Password Minimum 6 Characters');
      }
      formKey.currentState.save();
      setState(() {
        loading = true;
      });
      final response = await Provider.of<Auth>(context, listen: false).register(name, email, password);
      if(response["status"] == 200) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => TabsScreen()));
      }
      setState(() {
        loading = false;
      });
    } on HttpException catch(_) { 
      setState(() {
        loading = false;
      });
      SnackBar snackbar = SnackBar(
        backgroundColor: Colors.red[300],
        content: Text('Pengguna sudah tersedia'),
        action: SnackBarAction(
          textColor: Colors.white,
          label: 'Close',
          onPressed: () {
            Scaffold.of(context).hideCurrentSnackBar();
          }
        ),
      );
      Scaffold.of(context).showSnackBar(snackbar);
      // Fluttertoast.showToast(
      //   msg: error.toString(),
      //   toastLength: Toast.LENGTH_SHORT,
      //   backgroundColor: Colors.red.shade700,
      //   textColor: Colors.white
      // );
    } on Exception catch(error) {
      setState(() {
        loading = false;
      });
      String errorSplit = error.toString();
      List<String> errorText = errorSplit.split(":");
      SnackBar snackbar = SnackBar(
        backgroundColor: Colors.red[300],
        content: Text(errorText[1]),
        action: SnackBarAction(
          textColor: Colors.white,
          label: 'Close',
          onPressed: () {
            Scaffold.of(context).hideCurrentSnackBar();
          }
        ),
      );
      Scaffold.of(context).showSnackBar(snackbar);
    //   Fluttertoast.showToast(
    //     msg: error.toString(),
    //     toastLength: Toast.LENGTH_SHORT,
    //     backgroundColor: Colors.red.shade700,
    //     textColor: Colors.white
    //   );
    }
  }

  Widget buildNameTF() {
    return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Name',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
          color: Color(0xFF6CA8F1),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
          height: 60.0,
          child: TextFormField(
            keyboardType: TextInputType.text,
            style: TextStyle(
              color: Colors.white,
            ),
            controller: nameController,
            onSaved: (value) {
              name = value;
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.white,
              ),
              hintText: 'Enter your Name',
              hintStyle:  TextStyle(
                color: Colors.white54,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'E-mail Address',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
          color: Color(0xFF6CA8F1),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
          height: 60.0,
          child: TextFormField(
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
            style: TextStyle(
              color: Colors.white,
            ),
            // validator: (value) {
            //   if (value.isEmpty || !value.contains('@')) {
            //     return 'Invalid email!';
            //   }
            //   return null;
            // },
            onSaved: (value) {
              email = value;
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.white,
              ),
              hintText: 'Enter your Email',
              hintStyle:  TextStyle(
                color: Colors.white54,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration:  BoxDecoration(
            color: Color(0xFF6CA8F1),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextFormField(
            obscureText: obscure,
            controller: passwordController,
            style: TextStyle(
              color: Colors.white
            ),
            // validator: (value) {
              // if (value.isEmpty || value.length < 6) {
              //   return 'Password is too short!';
              // }
              // return null;
            // },
            onSaved: (value) {
              password  = value;    
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    obscure = !obscure;                                      
                  });
                },
              ),
              hintText: 'Enter your Password',
              hintStyle:  TextStyle(
                color: Colors.white54
              ),
            ),
          ),
        ),
      ],
    );
  }

 
  Widget buildRegisterBtn(context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      height: 100.0,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () => register(context),
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: loading ? Center(
          child: SizedBox(
            width: 18.0,
            height: 18.0,
            child: CircularProgressIndicator()
          )
        ) : Text(
          'SIGN UP',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  Widget buildSignInWithText() {
    return Column(
      children: <Widget>[
        Text(
          '- OR -',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 20.0),
        Text(
          'Sign up with',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
      ],
    );
  }

  Widget _buildSocialBtn(Function onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.0,
        width: 60.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSocialBtnRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildSocialBtn(
            () => print('Login with Facebook'),
          ),
          _buildSocialBtn(
            () => print('Login with Google'),
          ),
        ],
      ),
    );
  }

  Widget buildSignInBtn() {
    return GestureDetector(
      onTap: () => {
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName)
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Already have an Account ? ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Sign In',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
          builder: (context) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                Container(
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
                ),
                Form(
                  key: formKey,
                  child: Container(
                    height: double.infinity,
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 40.0,
                        vertical: 120.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 30.0),
                          buildNameTF(),
                          SizedBox(height: 30.0),
                          buildEmailTF(),
                          SizedBox(height: 30.0),
                          buildPasswordTF(),
             
                          buildRegisterBtn(context),
                          // buildSignInWithText(),
                          // buildSocialBtnRow(),
                          buildSignInBtn(),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}