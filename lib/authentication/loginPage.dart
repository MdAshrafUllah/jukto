import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../inside/welcomePage.dart';
import 'signupPage.dart';

class loginpage extends StatefulWidget {
  const loginpage({super.key});

  @override
  State<loginpage> createState() => _loginpageState();
}

class _loginpageState extends State<loginpage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool showSpinner = false;
  bool _passwordVisible = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 15,
              ),
              Center(
                child: Text(
                  "Jukto",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: Color.fromRGBO(58, 150, 255, 1),
                    fontSize: 65,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: Color.fromRGBO(162, 158, 158, 1),
                    fontSize: 25,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 60),
                child: Text(
                  'Login to your Account',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: Color.fromRGBO(162, 158, 158, 1),
                    fontSize: 18,
                  ),
                ),
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(left: 30),
              ),
              SizedBox(
                height: 25,
              ),
              Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                padding: EdgeInsets.only(left: 20, right: 20),
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 2,
                    color: Color.fromRGBO(162, 158, 158, 1),
                  ),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: _emailController,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: Colors.black54,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: Color.fromRGBO(58, 150, 255, 1),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(
                      fontFamily: 'Roboto',
                      color: Color.fromRGBO(162, 158, 158, 1),
                      fontSize: 18,
                    ),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                padding: EdgeInsets.only(left: 20, right: 20),
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 2,
                    color: Color.fromRGBO(162, 158, 158, 1),
                  ),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: _passwordController,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: Colors.black54,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: Color.fromRGBO(58, 150, 255, 1),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(
                      fontFamily: 'Roboto',
                      color: Color.fromRGBO(162, 158, 158, 1),
                      fontSize: 18,
                    ),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: Row(children: <Widget>[
                  Text(
                    'Forget Your Password?',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: Color.fromRGBO(162, 158, 158, 1),
                      fontSize: 18,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Click Here',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: Color.fromRGBO(58, 150, 255, 1),
                        fontSize: 18,
                      ),
                    ),
                  ),
                ]),
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(left: 30),
              ),
              SizedBox(
                height: 10,
              ),
              InkWell(
                child: Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  padding: EdgeInsets.only(left: 20, right: 20),
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(58, 150, 255, 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Sign in',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                onTap: () async {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (Context) => welcomePage()));

                  /* setState(() {
                    showSpinner = true;
                  });
                  try {
                    UserCredential userCredential =
                        await auth.signInWithEmailAndPassword(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );
                    user = userCredential.user;
                    if (user != null) {
                      Navigator.pushNamed(context, "profile");
                    }
                    setState(() {
                      showSpinner = false;
                    });
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'user-not-found') {
                      nouserAlertDialog(context);
                    } else if (e.code == 'wrong-password') {
                      wrongpassAlertDialog(context);
                    }
                  } catch (e) {
                    print(e);
                  }*/
                },
              ),
              SizedBox(
                height: 40,
              ),
              Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Don't have account?",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: Color.fromRGBO(162, 158, 158, 1),
                          fontSize: 18,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (Context) => signupPage()));
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: Color.fromRGBO(58, 150, 255, 1),
                            fontSize: 18,
                          ),
                        ),
                      )
                    ]),
              ),
            ]),
      ),
    );
  }
}
