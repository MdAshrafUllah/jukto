// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jukto/theme/theme.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

class UploadBooksPage extends StatefulWidget {
  const UploadBooksPage({super.key});

  @override
  UploadBooksPageState createState() => UploadBooksPageState();
}

class UploadBooksPageState extends State<UploadBooksPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  String newBookTitle = '';
  String newBookCategory = '';
  String newBookCover = '';
  String newBookPdf = '';
  bool _saving = false;
  String email = '';

  bool hasLicense = false;
  bool hasUploadedLicenseImage = false;
  String newLicenseImage = '';

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
          email = doc["email"];
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        newBookCover = pickedFile.path;
      });
    }
  }

  Future<void> _pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        newBookPdf = result.files.first.path!;
      });
    }
  }

  Future<void> _pickLicenseImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        newLicenseImage = pickedFile.path;
        hasUploadedLicenseImage =
            true; // Set the flag to true when the image is uploaded
      });
    }
  }

  Future<void> _uploadBook() async {
    setState(() {
      _saving = true; // Start the loading indicator
    });

    // Upload the image to Firebase Storage
    final imageStorageRef = FirebaseStorage.instance
        .ref()
        .child('book_covers')
        .child(DateTime.now().toString());
    final imageUploadTask = imageStorageRef.putFile(File(newBookCover));
    final imageTaskSnapshot = await imageUploadTask.whenComplete(() => null);
    final imageUrl = await imageTaskSnapshot.ref.getDownloadURL();

    // Upload the PDF to Firebase Storage
    final pdfStorageRef = FirebaseStorage.instance
        .ref()
        .child('books')
        .child('${DateTime.now()}.pdf');
    final pdfUploadTask = pdfStorageRef.putFile(File(newBookPdf));
    final pdfTaskSnapshot = await pdfUploadTask.whenComplete(() => null);
    final pdfUrl = await pdfTaskSnapshot.ref.getDownloadURL();

    // Upload the License Image to Firebase Storage (if it exists)
    String licenseImageUrl = '';
    if (hasLicense && newLicenseImage.isNotEmpty) {
      final licenseImageStorageRef = FirebaseStorage.instance
          .ref()
          .child('license_images')
          .child(DateTime.now().toString());
      final licenseImageUploadTask =
          licenseImageStorageRef.putFile(File(newLicenseImage));
      final licenseImageTaskSnapshot =
          await licenseImageUploadTask.whenComplete(() => null);
      licenseImageUrl = await licenseImageTaskSnapshot.ref.getDownloadURL();
    }

    // Save the book data with the image and PDF URLs to Firestore
    await FirebaseFirestore.instance.collection('books').add({
      'title': newBookTitle,
      'category': newBookCategory,
      'coverUrl': imageUrl,
      'fileUrl': pdfUrl,
      'email': email,
      'hasLicense': hasLicense,
      'licenseImage': licenseImageUrl, // Store license image URL if provided
    });

    // Clear the fields and stop the loading indicator
    setState(() {
      _saving = false;
      newBookTitle = '';
      newBookCategory = '';
      newBookCover = '';
      newBookPdf = '';
      hasLicense = false;
      newLicenseImage = '';
      hasUploadedLicenseImage = false;
    });
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.green,
      content: Text(
        'You Shared a Book Successfully',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Roboto',
        ),
      ),
    ));
  }

  Future<void> _showLicenseAgreementDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Agreements"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "You have no license for this book. So if the author or publication gives a copyright claim, JUKTO team will delete your book without your permission.",
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.redAccent),
                      )),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      _uploadBook(); // Start processing the uploading
                    },
                    child: const Text('Agree'),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upload Books',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 150, 255, 1),
        iconTheme: const IconThemeData(color: Colors.white, size: 35.0),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  style: TextStyle(
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.black,
                  ),
                  onChanged: (value) {
                    setState(() {
                      newBookTitle = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                TextField(
                  style: TextStyle(
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.black,
                  ),
                  onChanged: (value) {
                    setState(() {
                      newBookCategory = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextButton(
                  onPressed: _pickImage,
                  child: const Text('Pick Book Cover'),
                ),
                if (newBookCover.isNotEmpty)
                  Column(
                    children: [
                      Image.file(
                        File(newBookCover),
                        width: 100,
                        height: 100,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.redAccent,
                        ),
                        onPressed: () {
                          setState(() {
                            newBookCover = ''; // Clear selected image
                          });
                        },
                      ),
                    ],
                  ),
                TextButton(
                  onPressed: _pickPdf,
                  child: const Text('Pick PDF'),
                ),
                if (newBookPdf.isNotEmpty)
                  Column(
                    children: [
                      Text('Selected PDF: ${newBookPdf.split('/').last}'),
                      IconButton(
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.redAccent,
                        ),
                        onPressed: () {
                          setState(() {
                            newBookPdf = ''; // Clear selected PDF
                          });
                        },
                      ),
                    ],
                  ),
                Column(
                  children: [
                    const Text(
                      'You have the book licenses?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: hasLicense,
                              onChanged: (bool? value) {
                                setState(() {
                                  hasLicense = value ?? false;
                                });
                              },
                            ),
                            const Text('Yes'),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: !hasLicense,
                              onChanged: (bool? value) {
                                setState(() {
                                  hasLicense = !(value ?? true);
                                });
                              },
                            ),
                            const Text('No'),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
                Visibility(
                  visible: hasLicense,
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: () {
                          if (hasLicense) {
                            _pickLicenseImage();
                          }
                        },
                        child: const Text('Upload License Image'),
                      ),
                      if (hasUploadedLicenseImage && newLicenseImage.isNotEmpty)
                        Column(
                          children: [
                            Image.file(
                              File(newLicenseImage),
                              width: 100,
                              height: 100,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.cancel,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                setState(() {
                                  newLicenseImage =
                                      ''; // Clear selected license image
                                  hasUploadedLicenseImage = false;
                                });
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (newBookTitle.isNotEmpty &&
                            newBookCategory.isNotEmpty &&
                            newBookCover.isNotEmpty &&
                            newBookPdf.isNotEmpty) {
                          if (hasLicense) {
                            _uploadBook();
                          } else {
                            // Show the license agreement dialog
                            _showLicenseAgreementDialog();
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.redAccent,
                              content: Text(
                                'Required All Elements',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('Upload'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
