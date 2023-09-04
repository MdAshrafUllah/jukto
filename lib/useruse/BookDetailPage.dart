import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:jukto/theme/theme.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class BookDetailPage extends StatefulWidget {
  final String coverUrl;
  final String title;
  final String category;
  final String email;
  final String fileUrl;

  BookDetailPage({
    required this.coverUrl,
    required this.title,
    required this.category,
    required this.email,
    required this.fileUrl,
  });

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  String email = '';
  bool _isDeleting = false;
  bool _isDownloading = false;
  String _downloadProgress = '';

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

  Future<void> startDownload() async {
    try {
      final externalDir = await getExternalStorageDirectory();
      final taskId = await FlutterDownloader.enqueue(
        url: widget.fileUrl, // The URL of the file to download
        savedDir: externalDir!.path,
        showNotification: true, // Show download progress notification
        openFileFromNotification: true,
      );

      FlutterDownloader.registerCallback((id, status, progress) {
        if (id == taskId) {
          setState(() {
            _downloadProgress = '$progress%';
          });

          if (status == DownloadTaskStatus.complete) {
            setState(() {
              _isDownloading = false;
              _downloadProgress = 'Downloaded';
            });
          } else if (status == DownloadTaskStatus.failed) {
            setState(() {
              _isDownloading = false;
              _downloadProgress = 'Failed';
            });
          }
        }
      });

      setState(() {
        _isDownloading = true;
      });
    } catch (error) {
      print('Error starting download: $error');
    }
  }

  // Function to delete the book
  Future<void> deleteBook() async {
    try {
      // Show a confirmation dialog to confirm deletion
      bool confirmed = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Confirm Deletion',
              style: TextStyle(color: Colors.redAccent),
            ),
            content: Text(
              'Are you sure you want to delete this book?',
              style: TextStyle(
                  color: Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.white
                      : Colors.black),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(false); // Cancel deletion
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: Text('Delete'),
                onPressed: () {
                  Navigator.of(context).pop(true); // Confirm deletion
                },
              ),
            ],
          );
        },
      );

      if (confirmed == true) {
        // Show loading indicator
        setState(() {
          _isDeleting = true;
        });

        // Perform book deletion
        await FirebaseFirestore.instance
            .collection('books')
            .where('title', isEqualTo: widget.title)
            .where('email', isEqualTo: widget.email)
            .get()
            .then((querySnapshot) {
          querySnapshot.docs.forEach((doc) async {
            // Delete book details from Firestore
            await FirebaseFirestore.instance
                .collection('books')
                .doc(doc.id)
                .delete();

            // Delete book cover and file from Firebase Storage
            await FirebaseStorage.instance.refFromURL(widget.coverUrl).delete();
            await FirebaseStorage.instance.refFromURL(widget.fileUrl).delete();
          });
        });

        // Inform the user about successful deletion

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            content: Text(
              'Book Deleted Successfully',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto',
              ),
            )));

        // Navigate back to the previous screen or a designated screen
        Navigator.of(context).pop();
      }
    } catch (error) {
      // Handle any errors that occur during deletion
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          content: Text(
            'Error Deleting Book',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
          )));
    } finally {
      // Hide loading indicator regardless of success or failure
      setState(() {
        _isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Book Details',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 150, 255, 1),
        iconTheme: IconThemeData(color: Colors.white, size: 35.0),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isDeleting, // Show loading indicator if true
        child: Container(
          margin:
              EdgeInsets.only(left: size.width / 18, right: size.width / 18),
          child: Column(
            children: [
              Image.network(
                widget.coverUrl,
                width: size.width,
                height: size.height / 2,
              ),
              SizedBox(height: 20),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.category,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () => startDownload(),
                child: Container(
                  height: size.width / 7,
                  width: size.width,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(15)),
                  child: Center(
                    child: Text(
                      'Download',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (widget.email == email)
                InkWell(
                  onTap: () => deleteBook(),
                  child: Container(
                    height: size.width / 7,
                    width: size.width,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
