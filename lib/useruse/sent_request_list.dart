import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jukto/theme/theme.dart';
import 'package:provider/provider.dart';

import 'user_profile_page.dart';

class SentRequestPage extends StatefulWidget {
  const SentRequestPage({super.key});

  @override
  State<SentRequestPage> createState() => _SentRequestPageState();
}

class _SentRequestPageState extends State<SentRequestPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  String userID = '';

  @override
  void initState() {
    super.initState();
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
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sent Request",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 150, 255, 1),
        iconTheme: const IconThemeData(color: Colors.white, size: 35.0),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user?.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromRGBO(58, 150, 255, 1),
                  ),
                  strokeWidth: 2.0,
                ),
              ),
            );
          } else {
            var userData =
                snapshot.data?.docs.first.data() as Map<String, dynamic>;
            var friends = userData['sentRequest'] as List<dynamic>?;

            if (friends == null || friends.isEmpty) {
              return const Center(
                child: Text("No Sent Request"),
              );
            }

            return ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                var friend = friends[index] as Map<String, dynamic>;

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('email', isEqualTo: friend['email'])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromRGBO(58, 150, 255, 1)),
                            strokeWidth: 2.0,
                          ),
                        ),
                      );
                    } else {
                      var friend = snapshot.data?.docs.first.data()
                          as Map<String, dynamic>;
                      return Card(
                        margin:
                            const EdgeInsets.only(left: 10, right: 10, top: 10),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserProfilePage(
                                      profileImage: friend['profileImage'],
                                      name: friend['name'],
                                      email: friend['email'],
                                      bio: friend['bio'],
                                      university: friend['university'],
                                      city: friend['city'])),
                            );
                          },
                          title: Text(
                            friend['name'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                                friend['profileImage']),
                          ),
                          trailing: MaterialButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      'Cancel Request',
                                      style: TextStyle(
                                          color: themeProvider.isDarkMode
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                    content: Text(
                                      'Do you want to Cancel the Sent Request for ${friend['name']}?',
                                      style: TextStyle(
                                          color: themeProvider.isDarkMode
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text(
                                          'No',
                                          style: TextStyle(
                                              color: Colors.redAccent),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      ElevatedButton(
                                        child: const Text('Yes'),
                                        onPressed: () async {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                  content: Text(
                                                    'Friend Request Cancel',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: 'Roboto',
                                                    ),
                                                  )));
                                          Navigator.of(context).pop();
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(userID)
                                              .update({
                                            'sentRequest':
                                                FieldValue.arrayRemove([
                                              {
                                                'name': friend['name'],
                                                'email': friend['email'],
                                              }
                                            ])
                                          });

                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .where('email',
                                                  isEqualTo: friend['email'])
                                              .get()
                                              .then((QuerySnapshot
                                                  querySnapshot) {
                                            for (var doc
                                                in querySnapshot.docs) {
                                              FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(doc.id)
                                                  .update({
                                                'friendRequest':
                                                    FieldValue.arrayRemove([
                                                  {
                                                    'name': user?.displayName,
                                                    'email': user?.email,
                                                  }
                                                ])
                                              });
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            color: Colors.red,
                            child: const Text(
                              'Cancel Request',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
