import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jukto/theme/theme.dart';
import 'package:provider/provider.dart';

import 'book_detail_page.dart';
import 'upload_books_page.dart';

class EbooksPage extends StatefulWidget {
  const EbooksPage({super.key});

  @override
  EbooksPageState createState() => EbooksPageState();
}

class EbooksPageState extends State<EbooksPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ebook App',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 150, 255, 1),
        iconTheme: const IconThemeData(color: Colors.white, size: 35.0),
      ),
      body: RefreshIndicator(
        color: const Color.fromRGBO(58, 150, 255, 1),
        onRefresh: () async {
          return Future<void>.delayed(const Duration(seconds: 1));
        },
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              padding: const EdgeInsets.only(left: 20, right: 20),
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 2,
                  color: const Color.fromRGBO(162, 158, 158, 1),
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
                cursorColor: const Color.fromRGBO(58, 150, 255, 1),
                decoration: const InputDecoration(
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
            const SizedBox(
              height: 30,
            ),
            const Center(
              child: Text(
                'Share Your Books, Get your Books',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: Color.fromRGBO(162, 158, 158, 1),
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            searchQuery.isEmpty
                ? Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 18,
                      top: MediaQuery.of(context).size.height / 130,
                    ),
                    child: const Text(
                      'All Books',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 18,
                      top: MediaQuery.of(context).size.height / 130,
                    ),
                    child: const Text(
                      'Searching...',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('books').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
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
                                  license: book['hasLicense'],
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
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookDetailPage(
                                    license: book['hasLicense'],
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
        backgroundColor: const Color.fromRGBO(58, 150, 255, 1),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UploadBooksPage()),
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
