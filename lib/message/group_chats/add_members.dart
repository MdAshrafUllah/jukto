import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jukto/inside/profilePage.dart';
import 'package:jukto/message/group_chats/create_group/create_group.dart';
import 'package:jukto/message/group_chats/group_chat_screen.dart';
import 'package:jukto/message/group_chats/group_info.dart';
import 'package:jukto/theme/theme.dart';
import 'package:provider/provider.dart';

class AddMoreMembers extends StatefulWidget {
  final String groupChatId, name;
  final List membersList;
  const AddMoreMembers(
      {required this.name,
      required this.membersList,
      required this.groupChatId,
      Key? key})
      : super(key: key);

  @override
  State<AddMoreMembers> createState() => _AddMoreMembersState();
}

class _AddMoreMembersState extends State<AddMoreMembers> {
  bool isLoading = false;
  String name = "";
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  String userID = '';
  Map<String, dynamic>? userMap;
  List<Map<String, dynamic>> newMembersList = [];
  Map<String, String> selectedMember = {};
  bool currentUserDataAdded = false;

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
          CurrentPic = doc['profileImage'];
          print(CurrentPic);
        });
      });
    }
  }

  void onResultTap(Map<String, String> memberData) {
    bool isAlreadyExist =
        newMembersList.any((member) => member['email'] == memberData['email']);

    if (!isAlreadyExist) {
      setState(() {
        newMembersList.add({
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
  }

  void onRemoveMembers(int index) {
    if (newMembersList[index]['email'] != user!.email) {
      setState(() {
        newMembersList.removeAt(index);
      });
    }
  }

  bool _isMemberAlready(String userEmail) {
    return widget.membersList.any((member) => member['email'] == userEmail);
  }

  void onAddMembers() async {
    // Update the 'members' field in the groups collection
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupChatId)
        .update({
      'members': FieldValue.arrayUnion(newMembersList),
    });

    // Update each new member's subcollection in the users' collection
    for (var member in newMembersList) {
      await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: member['email'])
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(doc.id)
              .collection('groups')
              .doc(widget.groupChatId)
              .set({
            "name": widget.name,
            "id": widget.groupChatId,
          });
        });
      });
    }

    setState(() {
      newMembersList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Members',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(58, 150, 255, 1),
        iconTheme: IconThemeData(color: Colors.white, size: 35.0),
      ),
      body: Column(
        children: <Widget>[
          ListView.builder(
            itemCount: newMembersList.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              // Skip displaying current user's data in the list
              if (newMembersList[index]['email'] == user?.email) {
                return Container();
              }

              return ListTile(
                onTap: () {
                  setState(() {
                    onRemoveMembers(index);
                  });
                },
                leading: CircleAvatar(
                  foregroundImage: CachedNetworkImageProvider(
                    newMembersList[index]['profileImage'] ?? ' ',
                  ),
                ),
                title: Text(
                  newMembersList[index]['name'],
                  style: TextStyle(
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  newMembersList[index]['email'],
                  style: TextStyle(
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                trailing: Icon(
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
            margin: EdgeInsets.only(left: 20, right: 20),
            padding: EdgeInsets.only(left: 20, right: 20),
            height: size.height / 12,
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

                      if (data['email'] != user?.email &&
                          !_isMemberAlready(data['email'])) {
                        if (name.isEmpty) {
                          return Container();
                        }
                        if (data['name']
                            .toString()
                            .toLowerCase()
                            .startsWith(name.toLowerCase())) {
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
                            trailing: Icon(
                              Icons.add,
                              color: Colors.blue,
                            ),
                          );
                        }
                      }
                      return Container();
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: newMembersList.length >= 1
          ? FloatingActionButton(
              backgroundColor: Color.fromRGBO(58, 150, 255, 1),
              child: Icon(
                Icons.group_add,
                color: Colors.white,
              ),
              onPressed: () {
                onAddMembers();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => GroupChatHomeScreen()),
                );
              },
            )
          : SizedBox(),
    );
  }
}
