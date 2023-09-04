import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jukto/useruse/userProfilePage.dart';
import 'package:jukto/theme/theme.dart';
import 'package:provider/provider.dart';

class SearchPerson extends StatefulWidget {
  @override
  State<SearchPerson> createState() => _SearchPersonState();
}

class _SearchPersonState extends State<SearchPerson> {
  bool isLoading = false;
  String name = "";
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  String userID = '';
  Map<String, bool> addFriendMap = {};

  bool addFriend = false;

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
        querySnapshot.docs.forEach((doc) {
          String documentId = doc.id;
          userID = documentId;
        });
      });
    }
    addFriendMap = {};
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 25,
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
                hintText: 'User Name',
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
                  isLoading = true;
                  name = val;
                });
              },
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var data = snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;

                        if (data['email'] != user?.email) {
                          if (name.isEmpty) {
                            return Container();
                          }
                          if (data['name']
                              .toString()
                              .toLowerCase()
                              .startsWith(name.toLowerCase())) {
                            IconData trailingIcon;
                            Color trailingIconColor;

                            // Check if the user is already a friend
                            if (data['friends'] != null &&
                                data['friends'].any((friends) =>
                                    friends['email'] == user?.email)) {
                              trailingIcon = Icons.people;
                              trailingIconColor = Colors.grey;
                            }
                            // Check if the user is in the sent friend request list
                            else if (data['sentRequest'] != null &&
                                data['sentRequest'].any((request) =>
                                    request['email'] == user?.email)) {
                              trailingIcon = Icons.arrow_downward_rounded;
                              trailingIconColor = Colors.blue;
                            }
                            // Check if the user is in the received friend request list
                            else if (data['friendRequest'] != null &&
                                data['friendRequest'].any((request) =>
                                    request['email'] == user?.email)) {
                              trailingIcon = Icons.arrow_upward_rounded;
                              trailingIconColor = Colors.grey;
                            }
                            // Default case: user is not a friend and no friend request is sent or received
                            else {
                              trailingIcon = Icons.person_add;
                              trailingIconColor = Colors.blue;
                            }
                            return Card(
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserProfilePage(
                                        // Pass the necessary user data to the UserProfilePage
                                        name: data['name'],
                                        email: data['email'],
                                        profileImage: data['profileImage'],
                                        bio: data['bio'],
                                        university: data['university'],
                                        city: data['city'],
                                      ),
                                    ),
                                  );
                                },
                                title: Text(
                                  data['name'] ?? ' ',
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
                                subtitle: Text(
                                  data['email'] ?? ' ',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                leading: CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                      data['profileImage'] ?? ' '),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    trailingIcon,
                                    color: trailingIconColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (trailingIcon == Icons.person_add) {
                                        if (data['friends'] != null &&
                                            data['friends'].any((friends) =>
                                                friends['email'] ==
                                                user?.email)) {
                                          // User is already a friend, do not send friend request
                                          return;
                                        }
                                        // Toggle the addFriend state for the current user
                                        addFriendMap[data['email']] =
                                            !(addFriendMap[data['email']] ??
                                                false);

                                        // Add or remove the friend from the user's friend request list in Firestore
                                        if (addFriendMap[data['email']] ==
                                            true) {
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .where('email',
                                                  isEqualTo: data['email'])
                                              .get()
                                              .then((QuerySnapshot
                                                  querySnapshot) {
                                            querySnapshot.docs.forEach((doc) {
                                              FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(doc.id)
                                                  .update({
                                                'friendRequest':
                                                    FieldValue.arrayUnion([
                                                  {
                                                    'name': user?.displayName,
                                                    'email': user?.email,
                                                  }
                                                ])
                                              });
                                            });
                                          });
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(
                                                  userID) // Assuming userID is the document ID of the current user
                                              .update({
                                            'sentRequest':
                                                FieldValue.arrayUnion([
                                              {
                                                'name': data['name'],
                                                'email': data['email']
                                              }
                                            ])
                                          });
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  backgroundColor: Colors.green,
                                                  content: Text(
                                                    'Friend Request Sent',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: 'Roboto',
                                                    ),
                                                  )));
                                        }
                                      }
                                    });
                                  },
                                ),
                              ),
                            );
                          }
                        }
                        return Container();
                      });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
