import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jukto/theme/theme.dart';
import 'package:provider/provider.dart';

import 'BookDetailPage.dart';
import 'upload_books_page.dart';

class EbooksPage extends StatefulWidget {
  @override
  _EbooksPageState createState() => _EbooksPageState();
}

class _EbooksPageState extends State<EbooksPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ebook App',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 150, 255, 1),
        iconTheme: IconThemeData(color: Colors.white, size: 35.0),
      ),
      body: RefreshIndicator(
        color: const Color.fromRGBO(58, 150, 255, 1),
        onRefresh: () async {
          return Future<void>.delayed(const Duration(seconds: 1));
        },
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              padding: EdgeInsets.only(left: 20, right: 20),
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 2,
                  color: Color.fromRGBO(162, 158, 158, 1),
                ),
              ),
              alignment: Alignment.center,
              child: TextField(
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                keyboardType: TextInputType.name,
                cursorColor: Color.fromRGBO(58, 150, 255, 1),
                decoration: InputDecoration(
                  hintText: 'Book Name',
                  hintStyle: TextStyle(
                    fontFamily: 'Roboto',
                    color: Color.fromRGBO(162, 158, 158, 1),
                    fontSize: 18,
                  ),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() {
                    searchQuery = val
                        .toLowerCase(); // Convert to lowercase for case-insensitive search
                  });
                },
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Center(
              child: Text(
                'Share Your Books, Get your Books',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: Color.fromRGBO(162, 158, 158, 1),
                  fontSize: 18,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            searchQuery.isEmpty
                ? Container(
                    child: Text(
                      'All Books',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 18,
                      top: MediaQuery.of(context).size.height / 130,
                    ),
                  )
                : Container(
                    child: Text(
                      'Searching...',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 18,
                      top: MediaQuery.of(context).size.height / 130,
                    ),
                  ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('books').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final books = snapshot.data!.docs;

                  // Filter books based on the search query
                  final searchResults = books.where((book) {
                    final title = book['title'].toString().toLowerCase();
                    return title.contains(searchQuery);
                  }).toList();

                  return ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final book =
                          searchResults[index].data() as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookDetailPage(
                                  coverUrl: book['coverUrl'],
                                  title: book['title'],
                                  category: book['category'],
                                  email: book['email'],
                                  fileUrl: book['fileUrl'],
                                ),
                              ),
                            );
                          },
                          title: Text(
                            book['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            'Category: ${book['category']}',
                            style: TextStyle(
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          leading: Image.network(
                            book['coverUrl'],
                            fit: BoxFit.contain,
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.arrow_forward),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookDetailPage(
                                    coverUrl: book['coverUrl'],
                                    title: book['title'],
                                    category: book['category'],
                                    email: book['email'],
                                    fileUrl: book['fileUrl'],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color.fromRGBO(58, 150, 255, 1),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UploadBooksPage()),
          );
        },
        label: const Text(
          'Add Books',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
