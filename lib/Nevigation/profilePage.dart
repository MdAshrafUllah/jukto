import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jukto/alarm/examRoutine.dart';
import 'package:jukto/alarm/reminederPage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jukto/alarm/classRoutine.dart';
import 'package:jukto/calculator/CGPA.dart';
import 'package:jukto/theme/theme.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

import '../calculator/totalPayment.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

String imageurl = ' ';
String CurrentPic = ' ';
String addbio = ' ';
String Currentbio = ' ';
String bio = '';
String name = '';

class _ProfilePageState extends State<ProfilePage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      if (auth.currentUser != null) {
        setState(() {
          isLoading = true;
        });

        user = auth.currentUser;
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user?.email)
            .get();

        for (var doc in querySnapshot.docs) {
          setState(() {
            CurrentPic = doc["profileImage"];
            bio = doc['bio'];
            name = doc['name'];
          });
        }

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void uploadCameraImage() async {
    try {
      setState(() {
        isLoading = true; // Show the spinner
      });

      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString() +
          '_' +
          Random().nextInt(10000).toString() +
          '.jpg';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putFile(File(image!.path));
      String downloadUrl = await ref.getDownloadURL();
      ref.getDownloadURL().then((pImage) {
        setState(() {
          imageurl = pImage;
        });
      });

      // Update user's profile image in the 'users' collection
      FirebaseFirestore.instance
          .collection('users')
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          if (doc["email"] == user?.email) {
            FirebaseFirestore.instance
                .collection("users")
                .doc(doc.id)
                .update({'profileImage': downloadUrl.toString()});
          }
        });
      });

      // Update user's profile image in the 'posts' collection
      FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: user?.uid)
          .get()
          .then((QuerySnapshot postQuerySnapshot) {
        postQuerySnapshot.docs.forEach((postDoc) {
          FirebaseFirestore.instance
              .collection('posts')
              .doc(postDoc.id)
              .update({'profileImage': downloadUrl.toString()});

          // Update commenter's profile image in the 'comments' subcollection
          FirebaseFirestore.instance
              .collection('posts')
              .doc(postDoc.id)
              .collection('comments')
              .get()
              .then((QuerySnapshot commentQuerySnapshot) {
            commentQuerySnapshot.docs.forEach((commentDoc) {
              if (commentDoc["commenterEmail"] == user?.email) {
                FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postDoc.id)
                    .collection('comments')
                    .doc(commentDoc.id)
                    .update({'commenterProfileUrl': downloadUrl.toString()});
              }
            });
          });
        });
      });

      // Update commenter's profile image in the 'comments' subcollection
      FirebaseFirestore.instance
          .collection('posts')
          .get()
          .then((QuerySnapshot postQuerySnapshot) {
        postQuerySnapshot.docs.forEach((postDoc) {
          FirebaseFirestore.instance
              .collection('posts')
              .doc(postDoc.id)
              .collection('comments')
              .where('commenterEmail', isEqualTo: user?.email)
              .get()
              .then((QuerySnapshot commentQuerySnapshot) {
            commentQuerySnapshot.docs.forEach((commentDoc) {
              FirebaseFirestore.instance
                  .collection('posts')
                  .doc(postDoc.id)
                  .collection('comments')
                  .doc(commentDoc.id)
                  .update({'commenterProfileImage': downloadUrl.toString()});
            });
          });
        });
      });

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        content: Text(
          'Profile Picture updated successfully!',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
      ));
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        content: Text(
          'Error uploading profile picture.',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
      ));
    }
  }

  void uploadGalleryImage() async {
    try {
      setState(() {
        isLoading = true; // Show the spinner
      });

      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString() +
          '_' +
          Random().nextInt(10000).toString() +
          '.jpg';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putFile(File(image!.path));
      String downloadUrl = await ref.getDownloadURL();
      ref.getDownloadURL().then((pImage) {
        setState(() {
          imageurl = pImage;
        });
      });

      // Update user's profile image in the 'users' collection
      FirebaseFirestore.instance
          .collection('users')
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          if (doc["email"] == user?.email) {
            FirebaseFirestore.instance
                .collection("users")
                .doc(doc.id)
                .update({'profileImage': downloadUrl.toString()});
          }
        });
      });

      // Update user's profile image in the 'posts' collection
      FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: user?.uid)
          .get()
          .then((QuerySnapshot postQuerySnapshot) {
        postQuerySnapshot.docs.forEach((postDoc) {
          FirebaseFirestore.instance
              .collection('posts')
              .doc(postDoc.id)
              .update({'profileImage': downloadUrl.toString()});

          // Update commenter's profile image in the 'comments' subcollection
          FirebaseFirestore.instance
              .collection('posts')
              .doc(postDoc.id)
              .collection('comments')
              .get()
              .then((QuerySnapshot commentQuerySnapshot) {
            commentQuerySnapshot.docs.forEach((commentDoc) {
              if (commentDoc["commenterEmail"] == user?.email) {
                FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postDoc.id)
                    .collection('comments')
                    .doc(commentDoc.id)
                    .update({'commenterProfileUrl': downloadUrl.toString()});
              }
            });
          });
        });
      });

      // Update commenter's profile image in the 'comments' subcollection
      FirebaseFirestore.instance
          .collection('posts')
          .get()
          .then((QuerySnapshot postQuerySnapshot) {
        postQuerySnapshot.docs.forEach((postDoc) {
          FirebaseFirestore.instance
              .collection('posts')
              .doc(postDoc.id)
              .collection('comments')
              .where('commenterEmail', isEqualTo: user?.email)
              .get()
              .then((QuerySnapshot commentQuerySnapshot) {
            commentQuerySnapshot.docs.forEach((commentDoc) {
              FirebaseFirestore.instance
                  .collection('posts')
                  .doc(postDoc.id)
                  .collection('comments')
                  .doc(commentDoc.id)
                  .update({'commenterProfileImage': downloadUrl.toString()});
            });
          });
        });
      });

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        content: Text(
          'Profile Picture updated successfully!',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
      ));
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        content: Text(
          'Error uploading profile picture.',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 25,
              ),
              CircleAvatar(
                radius: 50.0,
                backgroundColor: const Color.fromRGBO(58, 150, 255, 1),
                child: CircleAvatar(
                  radius: 48.0,
                  backgroundImage: imageurl != " "
                      ? CachedNetworkImageProvider(imageurl)
                      : CachedNetworkImageProvider(CurrentPic),
                  child: Transform.translate(
                    offset: const Offset(30, 35),
                    child: IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Container(
                                  height: 120,
                                  child: Column(
                                    children: [
                                      ListTile(
                                        onTap: () {
                                          uploadCameraImage();
                                          Navigator.pop(context);
                                        },
                                        leading: const Icon(
                                          Icons.camera,
                                          color:
                                              Color.fromRGBO(58, 150, 255, 1),
                                        ),
                                        title: Text(
                                          'Camera',
                                          style: TextStyle(
                                              color: themeProvider.isDarkMode
                                                  ? Colors.white
                                                  : Colors.black),
                                        ),
                                      ),
                                      ListTile(
                                        onTap: () {
                                          uploadGalleryImage();
                                          Navigator.pop(context);
                                        },
                                        leading: const Icon(
                                          Icons.image,
                                          color:
                                              Color.fromRGBO(58, 150, 255, 1),
                                        ),
                                        title: Text('Gallery',
                                            style: TextStyle(
                                                color: themeProvider.isDarkMode
                                                    ? Colors.white
                                                    : Colors.black)),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      icon: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(
                              58, 150, 255, 1), // set the background color here
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  '$name',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  '$bio',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (Context) => const CGPAPage()));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 4,
                            color: const Color.fromRGBO(58, 150, 255, 1),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'CGPA',
                          style: TextStyle(
                            color: Color.fromRGBO(58, 150, 255, 1),
                            fontFamily: 'Roboto',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (Context) => const TotalPayments()));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 4,
                            color: const Color.fromRGBO(58, 150, 255, 1),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Payments',
                          style: TextStyle(
                            color: Color.fromRGBO(58, 150, 255, 1),
                            fontFamily: 'Roboto',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (Context) => ClassRoutinePage()));
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(58, 150, 255, 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Class Routine',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto',
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (Context) => ExamRoutinePage()));
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(58, 150, 255, 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Exam Routine',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto',
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (Context) => ReminderPage()));
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(58, 150, 255, 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Reminder',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto',
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
