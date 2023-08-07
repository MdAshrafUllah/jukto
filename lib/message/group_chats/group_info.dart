import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jukto/Nevigation/welcomePage.dart';
import 'package:jukto/message/group_chats/add_members.dart';

import 'package:jukto/theme/theme.dart';
import 'package:provider/provider.dart';

class GroupInfo extends StatefulWidget {
  final String groupId, groupName, memberpic, membername;
  const GroupInfo(
      {required this.groupId,
      required this.groupName,
      required this.memberpic,
      required this.membername,
      Key? key})
      : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  List membersList = [];
  bool isLoading = true;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getGroupDetails();
  }

  Future<void> getGroupDetails() async {
    DocumentSnapshot groupDoc =
        await _firestore.collection('groups').doc(widget.groupId).get();
    membersList = (groupDoc.data() as Map<String, dynamic>?)?['members'] ?? [];

    bool currentUserFound = false;
    String? currentUserEmail = _auth.currentUser!.email;

    for (int i = 0; i < membersList.length; i++) {
      Map<String, dynamic> member = membersList[i];
      if (member['email'] == currentUserEmail) {
        // Update existing member information
        member['name'] = widget.membername;
        member['profileImage'] = widget.memberpic;
        membersList[i] = member;
        currentUserFound = true;
        break;
      }
    }

    if (!currentUserFound) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => welcomePage()),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          content: Text(
            'You are Removed From the Group',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
          )));
    }

    // Update the 'members' field in the Firestore document
    await _firestore.collection('groups').doc(widget.groupId).update({
      'members': membersList,
    });

    isLoading = false;
    setState(() {});
  }

  bool checkAdmin() {
    bool isAdmin = false;

    membersList.forEach((element) {
      if (element['uid'] == _auth.currentUser!.uid) {
        isAdmin = element['isAdmin'];
      }
    });
    return isAdmin;
  }

  Future removeMembers(int index) async {
    String uid = membersList[index]['uid'];

    setState(() {
      isLoading = true;
      membersList.removeAt(index);
    });

    await _firestore.collection('groups').doc(widget.groupId).update({
      "members": membersList,
    }).then((value) async {
      await _firestore
          .collection('users')
          .where('uid', isEqualTo: uid)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(doc.id)
              .collection('groups')
              .doc(widget.groupId)
              .delete();
        });
      });

      setState(() {
        isLoading = false;
      });
    });
  }

  Future deletedGroup() async {
    String currentUserUid = _auth.currentUser!.uid;
    if (checkAdmin()) {
      setState(() {
        isLoading = true;
      });

      List<String> memberUids =
          membersList.map((member) => member['uid']).cast<String>().toList();

      final groupDocRef = _firestore.collection('groups').doc(widget.groupId);
      final chatQuerySnapshot = await groupDocRef.collection('chats').get();
      for (final doc in chatQuerySnapshot.docs) {
        await doc.reference.delete();
      }

      await groupDocRef.delete();

      for (String uid in memberUids) {
        _firestore
            .collection('users')
            .where('uid', isEqualTo: uid)
            .get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(doc.id)
                .collection('groups')
                .doc(widget.groupId)
                .delete();
          });
        });
      }

      setState(() {
        isLoading = false;
      });

      bool isCurrentUserMember = memberUids.contains(currentUserUid);

      if (isCurrentUserMember) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => welcomePage()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          content: Text(
            'The group has been deleted.',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
          ),
        ));
      } else {
        // Redirect to welcomePage if the current user was an admin but not a member of this group
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => welcomePage()),
          (route) => false,
        );
      }
    }
  }

  void showDialogBox(int index) {
    if (checkAdmin()) {
      if (_auth.currentUser!.uid != membersList[index]['uid']) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Remove This Member',
                  style: TextStyle(
                    color: Provider.of<ThemeProvider>(context).isDarkMode
                        ? Colors.white
                        : Colors.black,
                  )),
              content: Text('Do you want to Remove This Member From the Group?',
                  style: TextStyle(
                    color: Provider.of<ThemeProvider>(context).isDarkMode
                        ? Colors.white
                        : Colors.black,
                  )),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'No',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Yes'),
                  onPressed: () {
                    removeMembers(index);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  void groupDelete() {
    if (checkAdmin()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete This Group',
                style: TextStyle(
                  color: Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.white
                      : Colors.black,
                )),
            content: Text('Do you want to Delete This Group?',
                style: TextStyle(
                  color: Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.white
                      : Colors.black,
                )),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'No',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Text('Yes'),
                onPressed: () {
                  deletedGroup();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future onLeaveGroup() async {
    if (!checkAdmin()) {
      setState(() {
        isLoading = true;
      });

      for (int i = 0; i < membersList.length; i++) {
        if (membersList[i]['uid'] == _auth.currentUser!.uid) {
          membersList.removeAt(i);
        }
      }

      await _firestore.collection('groups').doc(widget.groupId).update({
        "members": membersList,
      });

      await _firestore
          .collection('users')
          .where('email', isEqualTo: _auth.currentUser!.email)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(doc.id)
              .collection('groups')
              .doc(widget.groupId)
              .delete();
        });
      });

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => welcomePage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? Container(
                height: size.height,
                width: size.width,
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: BackButton(),
                    ),
                    Container(
                      height: size.height / 8,
                      width: size.width / 1.1,
                      child: Row(
                        children: [
                          Container(
                            height: size.height / 11,
                            width: size.height / 11,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                            child: Icon(
                              Icons.group,
                              color: Colors.white,
                              size: size.width / 10,
                            ),
                          ),
                          SizedBox(
                            width: size.width / 20,
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                widget.groupName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: size.width / 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    //

                    SizedBox(
                      height: size.height / 20,
                    ),

                    Container(
                      width: size.width / 1.1,
                      child: Text(
                        "${membersList.length} Members",
                        style: TextStyle(
                          fontSize: size.width / 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(
                      height: size.height / 20,
                    ),

                    // Members Name

                    checkAdmin()
                        ? ListTile(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AddMoreMembers(
                                  groupChatId: widget.groupId,
                                  name: widget.groupName,
                                  membersList: membersList,
                                ),
                              ),
                            ),
                            leading: Icon(
                              Icons.add,
                            ),
                            title: Text(
                              "Add Members",
                              style: TextStyle(
                                color: themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: size.width / 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : SizedBox(),

                    Flexible(
                      child: ListView.builder(
                        itemCount: membersList.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () => showDialogBox(index),
                            leading: CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                              membersList[index]['profileImage'],
                            )),
                            title: Text(
                              membersList[index]['name'],
                              style: TextStyle(
                                color: themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: size.width / 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              membersList[index]['email'],
                              style: TextStyle(
                                color: themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            trailing: Text(
                                membersList[index]['isAdmin'] ? "Admin" : ""),
                          );
                        },
                      ),
                    ),

                    ListTile(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Leave The Group',
                                  style: TextStyle(
                                    color: themeProvider.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  )),
                              content: Text('Do you want to Leave The Group?',
                                  style: TextStyle(
                                    color: themeProvider.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  )),
                              actions: <Widget>[
                                TextButton(
                                  child: Text(
                                    'No',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ElevatedButton(
                                  child: Text('Yes'),
                                  onPressed: () {
                                    onLeaveGroup();
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      leading: Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                      ),
                      title: Text(
                        "Leave Group",
                        style: TextStyle(
                          fontSize: size.width / 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),

                    checkAdmin()
                        ? GestureDetector(
                            child: Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete_forever,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Delete Group",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: size.width / 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              groupDelete();
                            },
                          )
                        : SizedBox(),
                  ],
                ),
              ),
      ),
    );
  }
}
