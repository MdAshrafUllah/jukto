// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jukto/Nevigation/welcome_page.dart';
import 'package:jukto/info/termsand_conditions.dart';
import 'package:jukto/theme/theme.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
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
      'bio': '',
      'university': '',
      'city': ''
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
          child: SizedBox(
            height: size.height,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 15,
                  ),
                  const Center(
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
                  const SizedBox(
                    height: 10,
                  ),
                  const Center(
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
                    margin: const EdgeInsets.only(top: 20),
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(left: 30),
                    child: const Text(
                      'Create your Account',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: Color.fromRGBO(162, 158, 158, 1),
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 2,
                        color: const Color.fromRGBO(162, 158, 158, 1),
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
                      cursorColor: const Color.fromRGBO(58, 150, 255, 1),
                      decoration: const InputDecoration(
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
                  const SizedBox(
                    height: 25,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 2,
                        color: const Color.fromRGBO(162, 158, 158, 1),
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
                      cursorColor: const Color.fromRGBO(58, 150, 255, 1),
                      decoration: const InputDecoration(
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
                        _emailController.value =
                            _emailController.value.copyWith(
                          text: value.toLowerCase(), // Convert to lowercase
                          selection: TextSelection.collapsed(
                              offset: value.length), // Preserve cursor position
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 2,
                        color: const Color.fromRGBO(162, 158, 158, 1),
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
                      cursorColor: const Color.fromRGBO(58, 150, 255, 1),
                      obscureText: _passwordVisible,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: const TextStyle(
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
                  const SizedBox(
                    height: 25,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 2,
                        color: const Color.fromRGBO(162, 158, 158, 1),
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
                      cursorColor: const Color.fromRGBO(58, 150, 255, 1),
                      obscureText: _passwordVisible2,
                      decoration: InputDecoration(
                        hintText: 'Conform Password',
                        hintStyle: const TextStyle(
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
                    padding: const EdgeInsets.only(left: 15, top: 10),
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Checkbox(
                            activeColor: const Color.fromRGBO(58, 150, 255, 1),
                            value: isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                isChecked = value!;
                              });
                            }),
                        Container(
                          padding: const EdgeInsets.only(top: 10, bottom: 1),
                          width: size.width / 1.29,
                          child: RichText(
                            text: TextSpan(children: <TextSpan>[
                              TextSpan(
                                text:
                                    "By creating an account you agree to the ",
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  color: Theme.of(context).iconTheme.color,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: " terms of use",
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  color: Color.fromRGBO(58, 150, 255, 1),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            const TermsandConditions(),
                                      ),
                                    );
                                  },
                              ),
                              TextSpan(
                                text: " and our",
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  color: Theme.of(context).iconTheme.color,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: " privacy policy",
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  color: Color.fromRGBO(58, 150, 255, 1),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            const TermsandConditions(),
                                      ),
                                    );
                                  },
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  InkWell(
                    child: Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(58, 150, 255, 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
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
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
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
                                      builder: (Context) =>
                                          const WelcomePage()));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.green,
                                      content: Text(
                                        '${user!.displayName} Welcome To Jukto',
                                        style: const TextStyle(
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
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
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
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
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
                          }
                        } else {
                          setState(() {
                            showSpinner = false;
                          });
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
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
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
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
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          "Already have Account?",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: Color.fromRGBO(162, 158, 158, 1),
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            ' Sign in',
                            style: TextStyle(
                                fontFamily: 'Roboto',
                                color: Color.fromRGBO(58, 150, 255, 1),
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ]),
                  const SizedBox(
                    height: 25,
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
