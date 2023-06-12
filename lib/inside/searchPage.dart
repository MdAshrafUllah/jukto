import 'package:flutter/material.dart';

class searchPerson extends StatefulWidget {
  const searchPerson({super.key});

  @override
  State<searchPerson> createState() => _searchPersonState();
}

class _searchPersonState extends State<searchPerson> {
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
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
          // controller: _searchPersonController,
          style: TextStyle(
            fontFamily: 'Roboto',
            color: Colors.black54,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          keyboardType: TextInputType.emailAddress,
          cursorColor: Color.fromRGBO(58, 150, 255, 1),
          decoration: InputDecoration(
            hintText: 'User Name',
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
            'Search',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        onTap: () async {
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
    ]);
  }
}
