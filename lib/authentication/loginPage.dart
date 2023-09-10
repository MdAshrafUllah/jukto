import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:jukto/Nevigation/welcomePage.dart';
import 'package:jukto/authentication/forgatePassword.dart';
import 'package:jukto/theme/theme.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'signupPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool showSpinner = false;
  bool _passwordVisible = true;

  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  SharedPreferences? _prefs;
  final String _cacheKey = 'loggedIn';

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    _prefs ??= await SharedPreferences.getInstance();
    final bool isLoggedIn = _prefs!.getBool(_cacheKey) ?? false;
    if (isLoggedIn) {
      try {
        User? currentUser = auth.currentUser;
        if (currentUser != null) {
          setState(() {
            showSpinner = true;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const welcomePage()),
          );
        }
      } catch (e) {
      } finally {
        setState(() {
          showSpinner = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SingleChildScrollView(
          child: Container(
            height: size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                    "Welcome Back",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: Color.fromRGBO(162, 158, 158, 1),
                      fontSize: 25,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 60),
                  child: const Text(
                    'Login to your Account',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: Color.fromRGBO(162, 158, 158, 1),
                      fontSize: 18,
                    ),
                  ),
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(left: 30),
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
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(
                          r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$'))
                    ],
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
                      _emailController.value = _emailController.value.copyWith(
                        text: value.toLowerCase(),
                        selection:
                            TextSelection.collapsed(offset: value.length),
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
                  height: 10,
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      const Text(
                        'Forget Your Password?',
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
                              builder: (BuildContext context) =>
                                  const ForgatePasswordPage(),
                            ),
                          );
                        },
                        child: const Text(
                          ' Click Here',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: Color.fromRGBO(58, 150, 255, 1),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(left: 30),
                ),
                const SizedBox(
                  height: 10,
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
                    if (_emailController.text.length > 5 &&
                        _emailController.text.contains('@') &&
                        _emailController.text.endsWith('.com')) {
                      if (_emailController.text != "" &&
                          _passwordController.text != "") {
                        try {
                          setState(() {
                            showSpinner = true;
                          });
                          UserCredential userCredential =
                              await auth.signInWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                          user = userCredential.user;
                          if (user != null) {
                            _prefs ??= await SharedPreferences.getInstance();
                            _prefs!.setBool(_cacheKey, true);

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const welcomePage()),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.green,
                                content: Text(
                                  '${user!.displayName} Welcome Back.',
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
                          if (e.code == 'user-not-found') {
                            setState(() {
                              showSpinner = false;
                            });
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.redAccent,
                                    content: Text(
                                      'User Not Found',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Roboto',
                                      ),
                                    )));
                          } else if (e.code == 'wrong-password') {
                            setState(() {
                              showSpinner = false;
                            });
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.redAccent,
                                    content: Text(
                                      'Wrong Password',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Roboto',
                                      ),
                                    )));
                          }
                        } catch (e) {}
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
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.redAccent,
                        content: Text(
                          'Enter a Valid Email',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ));
                    }
                  },
                ),
                const SizedBox(
                  height: 40,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        "Don't have an account?",
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
                              builder: (BuildContext context) =>
                                  const signupPage(),
                            ),
                          );
                        },
                        child: const Text(
                          ' Sign Up',
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              color: Color.fromRGBO(58, 150, 255, 1),
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void nouserAlertDialog(BuildContext context) {
  Widget okButton = TextButton(
    child: Text(
      "OK",
      style: TextStyle(color: Theme.of(context).iconTheme.color),
    ),
    onPressed: () {
      Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const LoginPage(),
        ),
      );
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text(
      "⚠ Warning",
      style: TextStyle(color: Theme.of(context).iconTheme.color),
    ),
    content: Text(
      "No User Found",
      style: TextStyle(color: Theme.of(context).iconTheme.color),
    ),
    actions: [
      okButton,
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void wrongpassAlertDialog(BuildContext context) {
  Widget okButton = TextButton(
    child: Text(
      "OK",
      style: TextStyle(color: Theme.of(context).iconTheme.color),
    ),
    onPressed: () {
      Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const LoginPage(),
        ),
      );
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text(
      "⚠ Warning",
      style: TextStyle(color: Theme.of(context).iconTheme.color),
    ),
    content: Text(
      "Wrong password provided.",
      style: TextStyle(color: Theme.of(context).iconTheme.color),
    ),
    actions: [
      okButton,
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
