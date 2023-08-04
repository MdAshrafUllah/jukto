import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jukto/theme/theme.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import '../inside/welcomePage.dart';
import 'loginPage.dart';

class signupPage extends StatefulWidget {
  const signupPage({super.key});

  @override
  State<signupPage> createState() => _signupPageState();
}

class _signupPageState extends State<signupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordController2 = TextEditingController();

  bool showSpinner = false;
  bool _passwordVisible = true;
  bool _passwordVisible2 = true;
  bool isChecked = true;

  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  Future userdata(String name, String email) async {
    await FirebaseFirestore.instance.collection("users").add({
      'name': name,
      'email': email,
      'status': 'Unavalible',
      'uid': auth.currentUser?.uid,
      'profileImage': 'https://i.stack.imgur.com/YaL3s.jpg',
      'bio': ''
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SingleChildScrollView(
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
                    "Have a Nice Journey",
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
                    'Create your Account',
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
                    controller: _nameController,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    keyboardType: TextInputType.name,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[A-Za-z ]'))
                    ],
                    cursorColor: Color.fromRGBO(58, 150, 255, 1),
                    decoration: InputDecoration(
                      hintText: 'Name',
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
                    controller: _emailController,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
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
                    onChanged: (value) {
                      _emailController.value = _emailController.value.copyWith(
                        text: value.toLowerCase(), // Convert to lowercase
                        selection: TextSelection.collapsed(
                            offset: value.length), // Preserve cursor position
                      );
                    },
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
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    cursorColor: Color.fromRGBO(58, 150, 255, 1),
                    obscureText: _passwordVisible,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(
                        fontFamily: 'Roboto',
                        color: Color.fromRGBO(162, 158, 158, 1),
                        fontSize: 18,
                      ),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
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
                    controller: _passwordController2,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    cursorColor: Color.fromRGBO(58, 150, 255, 1),
                    obscureText: _passwordVisible2,
                    decoration: InputDecoration(
                      hintText: 'Conform Password',
                      hintStyle: TextStyle(
                        fontFamily: 'Roboto',
                        color: Color.fromRGBO(162, 158, 158, 1),
                        fontSize: 18,
                      ),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible2
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible2 = !_passwordVisible2;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 15, top: 10),
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Container(
                        child: Checkbox(
                            activeColor: Color.fromRGBO(58, 150, 255, 1),
                            value: isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                isChecked = value!;
                              });
                            }),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10, bottom: 1),
                        width: size.width / 1.29,
                        child: RichText(
                          text: TextSpan(children: <TextSpan>[
                            TextSpan(
                              text: "By creating an account you agree to the ",
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                color: Theme.of(context).iconTheme.color,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                                text: " terms of use",
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  color: Color.fromRGBO(58, 150, 255, 1),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                )),
                            TextSpan(
                                text: " and our",
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  color: Theme.of(context).iconTheme.color,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                )),
                            TextSpan(
                                text: " privacy policy",
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  color: Color.fromRGBO(58, 150, 255, 1),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                )),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 25,
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
                      'Sign up',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  onTap: () async {
                    if (isChecked == false) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.redAccent,
                          content: Text(
                            'Agree With Our terms and conditions',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Roboto',
                            ),
                          )));
                    } else if (_nameController.text != "" &&
                        _emailController.text != "" &&
                        _passwordController.text != "" &&
                        _passwordController2.text != "") {
                      if (_passwordController.text ==
                          _passwordController2.text) {
                        setState(() {
                          showSpinner = true;
                        });
                        try {
                          UserCredential userCredential = await FirebaseAuth
                              .instance
                              .createUserWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                          userdata(
                            _nameController.text.trim(),
                            _emailController.text.trim(),
                          );
                          user = userCredential.user;
                          await user!.updateDisplayName(_nameController.text);
                          await user!.reload();
                          user = auth.currentUser;

                          if (user != null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (Context) => welcomePage()));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.green,
                                content: Text(
                                  '${user!.displayName} Welcome To Jukto',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Roboto',
                                  ),
                                )));
                          }
                          setState(() {
                            showSpinner = false;
                          });
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'weak-password') {
                            setState(() {
                              showSpinner = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.redAccent,
                                content: Text(
                                  'The password provided is too weak.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Roboto',
                                  ),
                                )));
                          } else if (e.code == 'email-already-in-use') {
                            setState(() {
                              showSpinner = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.redAccent,
                                content: Text(
                                  'The email already used by another user.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Roboto',
                                  ),
                                )));
                          }
                        } catch (e) {
                          print(e);
                        }
                      } else {
                        setState(() {
                          showSpinner = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.redAccent,
                            content: Text(
                              'password does not match each other',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Roboto',
                              ),
                            )));
                      }
                    } else {
                      setState(() {
                        showSpinner = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.redAccent,
                          content: Text(
                            'All field required',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Roboto',
                            ),
                          )));
                    }
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
                          "Already have Account?",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: Color.fromRGBO(162, 158, 158, 1),
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (Context) => LoginPage()));
                          },
                          child: Text(
                            ' Sign in',
                            style: TextStyle(
                                fontFamily: 'Roboto',
                                color: Color.fromRGBO(58, 150, 255, 1),
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ]),
                ),
                SizedBox(
                  height: 25,
                ),
              ]),
        ),
      ),
    );
  }
}
