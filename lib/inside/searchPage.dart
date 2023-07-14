import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jukto/inside/ChatRoom.dart';
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

  String chatRoomId(String uid1, String uid2) {
    String channelId;
    if (uid1.compareTo(uid2) < 0) {
      channelId = "$uid1-$uid2";
    } else {
      channelId = "$uid2-$uid1";
    }
    return channelId;
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
            height: 70,
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
                          return Card(
                            child: ListTile(
                              onTap: () {
                                String roomId = chatRoomId(
                                    auth.currentUser!.displayName!,
                                    data['name']);

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ChatRoom(
                                      chatRoomId: roomId,
                                      userMap: data,
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
                                backgroundImage:
                                    NetworkImage(data['profileImage'] ?? ' '),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  addFriendMap[data['email']] == true
                                      ? Icons.person_add_alt_1
                                      : Icons.person_add,
                                  color: addFriendMap[data['email']] == true
                                      ? Colors.grey
                                      : Colors.blue,
                                ),
                                onPressed: () {
                                  setState(() {
                                    // Toggle the addFriend state for the current user
                                    addFriendMap[data['email']] =
                                        !(addFriendMap[data['email']] ?? false);
                                  });
                                },
                              ),
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
    );
  }
}
