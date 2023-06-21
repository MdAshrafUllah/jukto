import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../authentication/loginPage.dart';
import '../calculator/totalcgpa.dart';

class profilePage extends StatefulWidget {
  const profilePage({super.key});

  @override
  State<profilePage> createState() => _profilePageState();
}

String imageurl = ' ';
String CurrentPic = ' ';
String addbio = ' ';
String Currentbio = ' ';

class _profilePageState extends State<profilePage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    if (auth.currentUser != null) {
      user = auth.currentUser;
    }
  }

  // FirebaseFirestore.instance
  //     .collection('users')
  //     .get()
  //     .then((QuerySnapshot querySnapshot) {
  //   querySnapshot.docs.forEach((doc) {
  //     if (doc["email"] == user?.email) {
  //       setState(() {
  //         CurrentPic = doc["profileImage"];
  //       });
  //     }
  //   });
  // });

  void uploadCameraImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString() +
        '_' +
        Random().nextInt(10000).toString() +
        '.jpg';
    Reference ref = FirebaseStorage.instance.ref().child(fileName);
    await ref.putFile(File(image!.path));
    ref.getDownloadURL().then((pImage) {
      print(pImage);
      setState(() {
        imageurl = pImage;
      });
    });
    String downloadUrl = await ref.getDownloadURL();
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
  }

  void uploadGalleryImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString() +
        '_' +
        Random().nextInt(10000).toString() +
        '.jpg';
    Reference ref = FirebaseStorage.instance.ref().child(fileName);
    await ref.putFile(File(image!.path));
    ref.getDownloadURL().then((pImage) {
      setState(() {
        imageurl = pImage;
      });
    });
    String downloadUrl = await ref.getDownloadURL();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 25,
            ),
            CircleAvatar(
              child: ClipOval(
                child: Stack(
                  children: <Widget>[
                    Image.network('https://via.placeholder.com/300'),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      height: 33,
                      child: GestureDetector(
                        onTap: () {
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
                                          leading: Icon(
                                            Icons.camera,
                                            color:
                                                Color.fromRGBO(58, 150, 255, 1),
                                          ),
                                          title: Text('Camera'),
                                        ),
                                        ListTile(
                                          onTap: () {
                                            uploadGalleryImage();
                                            Navigator.pop(context);
                                          },
                                          leading: Icon(
                                            Icons.image,
                                            color:
                                                Color.fromRGBO(58, 150, 255, 1),
                                          ),
                                          title: Text('Gallery'),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                        child: Container(
                          height: 20,
                          width: 30,
                          color: Colors.black26,
                          child: Center(
                            child: Icon(
                              Icons.photo_camera,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              radius: 50.0,
              backgroundImage: imageurl != " "
                  ? NetworkImage(imageurl)
                  : NetworkImage(CurrentPic),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                '${user?.displayName}',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'bio',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (Context) => totalCGPApage()));
              },
              child: Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                padding: EdgeInsets.only(left: 20, right: 20),
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 4,
                    color: Color.fromRGBO(58, 150, 255, 1),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Total CGPA: 3.33',
                  style: TextStyle(
                    color: Color.fromRGBO(58, 150, 255, 1),
                    fontFamily: 'Roboto',
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (Context) => loginpage()));
              },
              child: Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                padding: EdgeInsets.only(left: 20, right: 20),
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 4,
                    color: Color.fromRGBO(58, 150, 255, 1),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Complete Credits: 129',
                  style: TextStyle(
                    color: Color.fromRGBO(58, 150, 255, 1),
                    fontFamily: 'Roboto',
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (Context) => loginpage()));
              },
              child: Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                padding: EdgeInsets.only(left: 20, right: 20),
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 4,
                    color: Color.fromRGBO(58, 150, 255, 1),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Complete Subjects: 43',
                  style: TextStyle(
                    color: Color.fromRGBO(58, 150, 255, 1),
                    fontFamily: 'Roboto',
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (Context) => loginpage()));
              },
              child: Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                padding: EdgeInsets.only(left: 20, right: 20),
                height: 70,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(58, 150, 255, 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Total Payments',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Roboto',
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (Context) => loginpage()));
              },
              child: Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                padding: EdgeInsets.only(left: 20, right: 20),
                height: 70,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(58, 150, 255, 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
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
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (Context) => loginpage()));
              },
              child: Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                padding: EdgeInsets.only(left: 20, right: 20),
                height: 70,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(58, 150, 255, 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
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
            SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
    );
  }
}
