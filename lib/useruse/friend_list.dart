import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jukto/theme/theme.dart';
import 'package:jukto/useruse/user_profile_page.dart';
import 'package:provider/provider.dart';

class FriendList extends StatefulWidget {
  const FriendList({super.key});

  @override
  State<FriendList> createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
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
          "All Friends",
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
            var friends = userData['friends'] as List<dynamic>?;

            if (friends == null || friends.isEmpty) {
              return const Center(
                child: Text("No Friends"),
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
                                    title: Text('Remove User',
                                        style: TextStyle(
                                          color: themeProvider.isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        )),
                                    content: Text(
                                        'Do you want to remove ${friend['name']} From your Friend List?',
                                        style: TextStyle(
                                          color: themeProvider.isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        )),
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
                                                    'Friend Remove Successfully!',
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
                                            'friends': FieldValue.arrayRemove([
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
                                                'friends':
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
                              'Remove',
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
