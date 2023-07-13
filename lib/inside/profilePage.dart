import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jukto/alarm/classRemineder.dart';
import 'package:image_picker/image_picker.dart';

import '../authentication/loginPage.dart';
import '../calculator/totalPayment.dart';
import '../calculator/totalcgpa.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

String imageurl = ' ';
String CurrentPic = ' ';
String addbio = ' ';
String Currentbio = ' ';

class _ProfilePageState extends State<ProfilePage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  double totalCGPA = 3.27;
  double totalCredit = 127;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    if (auth.currentUser != null) {
      user = auth.currentUser;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user?.email)
          .get();

      for (var doc in querySnapshot.docs) {
        setState(() {
          CurrentPic = doc["profileImage"];
          final totalPoint = doc["totalPoint"];
          final totalCreditValue = doc["totalCredit"];
          if (totalPoint is num) {
            totalCGPA = totalPoint.toDouble();
          }
          if (totalCreditValue is num) {
            totalCredit = totalCreditValue.toDouble();
          }
        });
      }
    }
  }

  void uploadCameraImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
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
              radius: 50.0,
              backgroundColor: Color.fromRGBO(58, 150, 255, 1),
              child: CircleAvatar(
                radius: 48.0,
                backgroundImage: imageurl != " "
                    ? NetworkImage(imageurl)
                    : NetworkImage(CurrentPic),
                child: Transform.translate(
                  offset: Offset(30, 35),
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
                                      leading: Icon(
                                        Icons.camera,
                                        color: Color.fromRGBO(58, 150, 255, 1),
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
                                        color: Color.fromRGBO(58, 150, 255, 1),
                                      ),
                                      title: Text('Gallery'),
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
                        color: Color.fromRGBO(
                            58, 150, 255, 1), // set the background color here
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
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
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (Context) => const TotalCGPApage()));
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 20, right: 20),
                      padding: EdgeInsets.only(left: 5, right: 5),
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
                        'Total CGPA',
                        style: TextStyle(
                          color: Color.fromRGBO(58, 150, 255, 1),
                          fontFamily: 'Roboto',
                          fontSize: 25,
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
                              builder: (Context) => TotalPayments()));
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 20, right: 20),
                      padding: EdgeInsets.only(left: 5, right: 5),
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (Context) => ClassReminderPage()));
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
                    MaterialPageRoute(builder: (Context) => LoginPage()));
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
