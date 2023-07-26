import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jukto/theme/theme.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  String userID = '';
  TextEditingController nameCngController = TextEditingController();
  TextEditingController bioCngController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    if (auth.currentUser != null) {
      user = auth.currentUser;
      FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user?.email)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          String documentId = doc.id;
          userID = documentId;
          nameCngController.text = doc["name"];
          bioCngController.text = doc['bio'];
        });
      });
    }
  }

  Future<void> updateProfile() async {
    try {
      if (auth.currentUser != null) {
        user = auth.currentUser;
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(userID);

        await userRef.update({
          'name': nameCngController.text,
          'bio': bioCngController.text,
        });

        // Show a success message to the user
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            content: Text(
              'Profile Info updated successfully!',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto',
              ),
            )));
      }
    } catch (e) {
      // Show an error message if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          content: Text(
            'Error updating profile Info.',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
          )));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 150, 255, 1),
        iconTheme: IconThemeData(color: Colors.white, size: 35.0),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Proifle Information",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Name",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Roboto',
              ),
            ),
            SizedBox(
              height: 5,
            ),
            TextField(
              style: TextStyle(
                  color:
                      themeProvider.isDarkMode ? Colors.white : Colors.black),
              controller: nameCngController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Your Name",
                  suffixIcon: Icon(Icons.edit)),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              "Bio",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Roboto',
              ),
            ),
            SizedBox(
              height: 5,
            ),
            TextField(
              style: TextStyle(
                  color:
                      themeProvider.isDarkMode ? Colors.white : Colors.black),
              maxLength: 50,
              controller: bioCngController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Your Bio",
                  suffixIcon: Icon(Icons.edit)),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              "Email",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Roboto',
              ),
            ),
            SizedBox(
              height: 5,
            ),
            TextField(
                enabled: false,
                decoration: InputDecoration(
                  hintText: user?.email,
                  border: OutlineInputBorder(),
                )),
            SizedBox(
              height: 15,
            ),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Background color
                ),
                onPressed: () async {
                  await updateProfile();
                },
                child: Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
