import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jukto/Nevigation/profile_page.dart';
import 'package:jukto/message/group_chats/create_group/create_group.dart';
import 'package:jukto/theme/theme.dart';
import 'package:provider/provider.dart';

class AddMembersInGroup extends StatefulWidget {
  const AddMembersInGroup({super.key});

  @override
  State<AddMembersInGroup> createState() => _AddMembersInGroupState();
}

class _AddMembersInGroupState extends State<AddMembersInGroup> {
  bool isLoading = false;
  String name = "";
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  String userID = '';
  Map<String, bool> addFriendMap = {};
  List<Map<String, dynamic>> membersList = [];
  Map<String, String> selectedMember = {};
  bool currentUserDataAdded = false;

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
        for (var doc in querySnapshot.docs) {
          String documentId = doc.id;
          userID = documentId;
          currentPic = doc['profileImage'];
        }
      });
    }
    addFriendMap = {};
  }

  void onResultTap(Map<String, String> memberData) {
    bool isAlreadyExist =
        membersList.any((member) => member['email'] == memberData['email']);

    if (!isAlreadyExist) {
      setState(() {
        membersList.add({
          "profileImage": memberData['profileImage'],
          "name": memberData['name'],
          "email": memberData['email'],
          "uid": memberData['uid'],
          "isAdmin": false,
        });

        // Clear the selected member after adding to the list
        selectedMember.clear();
      });
    }

    // Add current user's data to the membersList only once
    if (!currentUserDataAdded) {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      if (user != null) {
        membersList.add({
          "profileImage":
              currentPic, // You can customize the default value if needed
          "name": user.displayName ??
              'Anonymous', // You can customize the default value if needed
          "email": user.email ?? '',
          "uid": user.uid,
          "isAdmin": true, // Assuming the current user is an admin
        });
      }
      currentUserDataAdded =
          true; // Set the flag to true to prevent adding again
    }
  }

  void onRemoveMembers(int index) {
    if (membersList[index]['email'] != user!.email) {
      setState(() {
        membersList.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Members',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 150, 255, 1),
        iconTheme: const IconThemeData(color: Colors.white, size: 35.0),
      ),
      body: Column(
        children: <Widget>[
          ListView.builder(
            itemCount: membersList.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              // Skip displaying current user's data in the list
              if (membersList[index]['email'] == user?.email) {
                return Container();
              }

              return ListTile(
                onTap: () => onRemoveMembers(index),
                leading: CircleAvatar(
                  foregroundImage: CachedNetworkImageProvider(
                    membersList[index]['profileImage'] ?? ' ',
                  ),
                ),
                title: Text(
                  membersList[index]['name'],
                  style: TextStyle(
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  membersList[index]['email'],
                  style: TextStyle(
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                trailing: const Icon(
                  Icons.close,
                  color: Colors.redAccent,
                ),
              );
            },
          ),
          SizedBox(
            height: size.height / 20,
          ),
          Container(
            margin: const EdgeInsets.only(left: 20, right: 20),
            padding: const EdgeInsets.only(left: 20, right: 20),
            height: size.height / 12,
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
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
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
                            return ListTile(
                              onTap: () {
                                setState(() {
                                  selectedMember = {
                                    "profileImage": data['profileImage'],
                                    "name": data['name'],
                                    "email": data['email'],
                                    "uid": data['uid'],
                                  };
                                });
                                onResultTap(selectedMember);
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
                                  data['profileImage'] ?? ' ',
                                ),
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
                                      if (addFriendMap[data['email']] == true) {
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .where('email',
                                                isEqualTo: data['email'])
                                            .get()
                                            .then(
                                                (QuerySnapshot querySnapshot) {
                                          for (var doc in querySnapshot.docs) {
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
                                          }
                                        });
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(
                                                userID) // Assuming userID is the document ID of the current user
                                            .update({
                                          'sentRequest': FieldValue.arrayUnion([
                                            {
                                              'name': data['name'],
                                              'email': data['email']
                                            }
                                          ])
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
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
      floatingActionButton: membersList.length >= 2
          ? FloatingActionButton(
              backgroundColor: const Color.fromRGBO(58, 150, 255, 1),
              child: const Icon(
                Icons.forward,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreateGroup(
                    membersList: membersList,
                  ),
                ),
              ),
            )
          : const SizedBox(),
    );
  }
}
