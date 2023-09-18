// ignore_for_file: use_build_context_synchronously

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
  TextEditingController universityController = TextEditingController();
  TextEditingController cityController = TextEditingController();

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
        for (var doc in querySnapshot.docs) {
          String documentId = doc.id;
          userID = documentId;
          nameCngController.text = doc["name"];
          bioCngController.text = doc['bio'];
          universityController.text = doc['university'];
          cityController.text = doc['city'];
        }
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
          'university': universityController.text,
          'city': cityController.text,
        });

        FirebaseFirestore.instance
            .collection('posts')
            .where('userId', isEqualTo: user?.uid)
            .get()
            .then((QuerySnapshot postQuerySnapshot) {
          for (var postDoc in postQuerySnapshot.docs) {
            FirebaseFirestore.instance
                .collection('posts')
                .doc(postDoc.id)
                .update({'name': nameCngController.text});
          }
        });

        // Update user's name in the 'posts' collection
        FirebaseFirestore.instance
            .collection('posts')
            .where('userId', isEqualTo: user?.uid)
            .get()
            .then((QuerySnapshot postQuerySnapshot) {
          for (var postDoc in postQuerySnapshot.docs) {
            FirebaseFirestore.instance
                .collection('posts')
                .doc(postDoc.id)
                .update({'name': nameCngController.text});

            // Update commenter's name in the 'comments' subcollection
            FirebaseFirestore.instance
                .collection('posts')
                .doc(postDoc.id)
                .collection('comments')
                .get()
                .then((QuerySnapshot commentQuerySnapshot) {
              for (var commentDoc in commentQuerySnapshot.docs) {
                if (commentDoc["commenterEmail"] == user?.email) {
                  FirebaseFirestore.instance
                      .collection('posts')
                      .doc(postDoc.id)
                      .collection('comments')
                      .doc(commentDoc.id)
                      .update({'commenterName': nameCngController.text});
                }
              }
            });
          }
        });

        // Update commenter's name in the 'comments' subcollection
        FirebaseFirestore.instance
            .collection('posts')
            .get()
            .then((QuerySnapshot postQuerySnapshot) {
          for (var postDoc in postQuerySnapshot.docs) {
            FirebaseFirestore.instance
                .collection('posts')
                .doc(postDoc.id)
                .collection('comments')
                .where('commenterEmail', isEqualTo: user?.email)
                .get()
                .then((QuerySnapshot commentQuerySnapshot) {
              for (var commentDoc in commentQuerySnapshot.docs) {
                FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postDoc.id)
                    .collection('comments')
                    .doc(commentDoc.id)
                    .update({'commenterName': nameCngController.text});
              }
            });
          }
        });

        // Show a success message to the user
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 150, 255, 1),
        iconTheme: const IconThemeData(color: Colors.white, size: 35.0),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Proifle Information",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Name",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
              style: TextStyle(
                  color:
                      themeProvider.isDarkMode ? Colors.white : Colors.black),
              controller: nameCngController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Your Name",
                  suffixIcon:
                      Icon(Icons.edit, color: Color.fromRGBO(58, 150, 255, 1))),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              "Bio",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
              style: TextStyle(
                  color:
                      themeProvider.isDarkMode ? Colors.white : Colors.black),
              maxLength: 50,
              controller: bioCngController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Your Bio",
                  suffixIcon:
                      Icon(Icons.edit, color: Color.fromRGBO(58, 150, 255, 1))),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              "Email",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
                enabled: false,
                decoration: InputDecoration(
                  hintText: user?.email,
                  border: const OutlineInputBorder(),
                )),
            const SizedBox(
              height: 5,
            ),
            const Text(
              "Your University",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
              style: TextStyle(
                  color:
                      themeProvider.isDarkMode ? Colors.white : Colors.black),
              maxLength: 100,
              controller: universityController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Your University Name",
                  suffixIcon:
                      Icon(Icons.edit, color: Color.fromRGBO(58, 150, 255, 1))),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              "Your City",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
              style: TextStyle(
                  color:
                      themeProvider.isDarkMode ? Colors.white : Colors.black),
              maxLength: 50,
              controller: cityController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Your City",
                  suffixIcon: Icon(
                    Icons.edit,
                    color: Color.fromRGBO(58, 150, 255, 1),
                  )),
            ),
            const SizedBox(
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
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
