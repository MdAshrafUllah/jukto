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
  @override
  _UploadBooksPageState createState() => _UploadBooksPageState();
}

class _UploadBooksPageState extends State<UploadBooksPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  String newBookTitle = '';
  String newBookCategory = '';
  String newBookCover = '';
  String newBookPdf = '';
  bool _saving = false;
  String email = '';

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
        .child(DateTime.now().toString() + '.pdf');
    final pdfUploadTask = pdfStorageRef.putFile(File(newBookPdf));
    final pdfTaskSnapshot = await pdfUploadTask.whenComplete(() => null);
    final pdfUrl = await pdfTaskSnapshot.ref.getDownloadURL();

    // Save the book data with the image and PDF URLs to Firestore
    await FirebaseFirestore.instance.collection('books').add({
      'title': newBookTitle,
      'category': newBookCategory,
      'coverUrl': imageUrl,
      'fileUrl': pdfUrl,
      'email': email
    });

    // Clear the fields and stop the loading indicator
    setState(() {
      _saving = false;
      newBookTitle = '';
      newBookCategory = '';
      newBookCover = '';
      newBookPdf = '';
    });
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        content: Text(
          'You Share a Book Sucessfully',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        )));
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
                      labelText: 'Title', border: OutlineInputBorder()),
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
                      labelText: 'Category', border: OutlineInputBorder()),
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
                          _uploadBook();
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.redAccent,
                                  content: Text(
                                    'Requred All Elements',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Roboto',
                                    ),
                                  )));
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
