import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// import 'package:fluttertoast/fluttertoast.dart';

import '../../providers/auth/auth.dart';
import './register.dart';
import '../tabs/tabs.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String email;
  String password;
  bool loading = false;
  bool rememberMe = false;
  bool obscure = true;

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login(context) async {
    // if (!formKey.currentState.validate()) {
    //   return;
    // }
    try {
      if (emailController.text.isEmpty || !emailController.text.contains('@')) {
        throw new Exception("Format Email Salah. \n Contoh johndoe@gmail.com");
      }
      if (passwordController.text.isEmpty || passwordController.text.length < 6) {
        throw new Exception("Kata Sandi Minimal 6 Karakter");
      }
      formKey.currentState.save();
      setState(() {
        loading = true;
      });
      final response = await Provider.of<Auth>(context, listen: false).login(email, password);
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
      // Fluttertoast.showToast(
      //   msg: error.toString(),
      //   toastLength: Toast.LENGTH_SHORT,
      //   backgroundColor: Colors.red.shade700,
      //   textColor: Colors.white
      // );
      SnackBar snackbar = SnackBar(
        backgroundColor: Colors.red[300],
        content: Text('Pengguna belum terdaftar'),
        action: SnackBarAction(
          textColor: Colors.white,
          label: 'Tutup',
          onPressed: () {
            Scaffold.of(context).hideCurrentSnackBar();
          }
        ),
      );
      Scaffold.of(context).showSnackBar(snackbar);
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
          label: 'Tutup',
          onPressed: () {
            Scaffold.of(context).hideCurrentSnackBar();
          }
        ),
      );
      Scaffold.of(context).showSnackBar(snackbar);
      // Fluttertoast.showToast(
      //   msg: errorText[1],
      //   toastLength: Toast.LENGTH_SHORT,
      //   backgroundColor: Colors.red.shade700,
      //   textColor: Colors.white
      // );
    }
  }

  Widget buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
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
            //   // if (value.isEmpty || !value.contains('@')) {
            //   //   return 'Invalid email';
            //   // }
            //   // return null;
            // },
            onSaved: (value) {
              setState(() {
                email = value;
              });
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
            controller: passwordController,
            obscureText: obscure,
            style: TextStyle(
              color: Colors.white
            ),
            // validator: (value) {
            //   if (value.isEmpty || value.length < 6) {
            //     return 'Password is too short!';
            //   }
            //   return null;
            // },
            onSaved: (value) {
              password = value;
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

  Widget buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: FlatButton(
        onPressed: () => print('Forgot Password Button Pressed'),
        padding: EdgeInsets.only(right: 0.0),
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  Widget buildRememberMeCheckbox() {
    return Container(
      height: 20.0,
      child: Row(
        children: <Widget>[
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.white),
            child: Checkbox(
              value: rememberMe,
              checkColor: Colors.green,
              activeColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  rememberMe = value;
                });
              },
            ),
          ),
          Text(
            'Remember me',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLoginBtn(context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      height: 100.0,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () => login(context),
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
          'LOGIN',
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

  // Widget buildSignInWithText() {
  //   return Column(
  //     children: <Widget>[
  //       Text(
  //         '- OR -',
  //         style: TextStyle(
  //           color: Colors.white,
  //           fontWeight: FontWeight.w400,
  //         ),
  //       ),
  //       SizedBox(height: 20.0),
  //       Text(
  //         'Sign in with',
  //         style: TextStyle(
  //           color: Colors.white,
  //           fontWeight: FontWeight.bold
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget buildSocialBtn(Function onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.0,
        width: 60.0,
      ),
    );
  }

  Widget buildSocialBtnRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          buildSocialBtn(
            () => print('Login with Facebook')
          ),
          buildSocialBtn(
            () => print('Login with Google')
          ),
        ],
      ),
    );
  }

  Widget buildSignupBtn() {
    return GestureDetector(
      onTap: () => {
        Navigator.of(context).pushReplacementNamed(RegisterScreen.routeName)
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Don\'t have an Account ? ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Sign Up',
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
              children: <Widget>[
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
                        children: <Widget>[
                          Text(
                            'Sign In',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 30.0),
                          buildEmailTF(),
                          SizedBox(
                            height: 30.0,
                          ),
                          buildPasswordTF(),
                          // buildForgotPasswordBtn(),
                          // buildRememberMeCheckbox(),
                          buildLoginBtn(context),
                          // buildSignInWithText(),
                          // buildSocialBtnRow(),
                          buildSignupBtn(),
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