import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jukto/message/group_chats/group_chat_screen.dart';
import 'package:jukto/message/ChatRoom.dart';
import 'package:jukto/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

IconData _iconLight = Icons.light_mode;
IconData _iconDark = Icons.dark_mode;

class _MessagePageState extends State<MessagePage> {
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
        querySnapshot.docs.forEach((doc) {
          String documentId = doc.id;
          userID = documentId;
        });
      });
    }
  }

  static String chatRoomId(String uid1, String uid2) {
    String channelId;
    if (uid1.compareTo(uid2) < 0) {
      channelId = "$uid1-$uid2";
    } else {
      channelId = "$uid2-$uid1";
    }
    return channelId;
  }

  Color getDotColor(String status) {
    if (status == 'Online') {
      return Colors.greenAccent;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: RefreshIndicator(
        color: Color.fromRGBO(58, 150, 255, 1),
        onRefresh: () async {
          getDotColor;
          return Future<void>.delayed(const Duration(seconds: 1));
        },
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: user?.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Container(
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
                return Center(
                  child: Text("No Friends"),
                );
              }

              return ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  var friend = friends[index] as Map<String, dynamic>;
                  String roomId = chatRoomId(
                      auth.currentUser!.displayName!, friend['name']);
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('email', isEqualTo: friend['email'])
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Container(
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
                        final status = friend['status'];
                        return ListTile(
                          onTap: () {
                            String roomId = chatRoomId(
                                auth.currentUser!.displayName!, friend['name']);

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatRoom(
                                  chatRoomId: roomId,
                                  userMap: friend,
                                ),
                              ),
                            );
                          },
                          title: Row(
                            children: [
                              Text(
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
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                width: 10,
                                height: 10,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: getDotColor(status),
                                ),
                              )
                            ],
                          ),
                          subtitle: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('chatroom')
                                .doc(roomId)
                                .collection('chats')
                                .orderBy("time", descending: true)
                                .limit(1)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text(
                                  'Loading...',
                                  style: TextStyle(
                                    color: themeProvider.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                );
                              } else if (snapshot.hasData &&
                                  snapshot.data!.docs.isNotEmpty) {
                                Map<String, dynamic> lastMessage =
                                    snapshot.data!.docs[0].data()
                                        as Map<String, dynamic>;
                                if (lastMessage['type'] == 'img') {
                                  return Text('Share a picture');
                                } else if (lastMessage['type'] == 'file') {
                                  return Text('Share a document');
                                } else {
                                  if (lastMessage['message'].toString().startsWith(
                                      'https://firebasestorage.googleapis.com')) {
                                    return Text('Share a picture',
                                        style: TextStyle(
                                          color: themeProvider.isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ));
                                  } else if (lastMessage['message']
                                          .toString()
                                          .startsWith('https://') ||
                                      lastMessage['message']
                                          .toString()
                                          .startsWith('.com')) {
                                    return Text('Share a Link',
                                        style: TextStyle(
                                          color: themeProvider.isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ));
                                  } else {
                                    return Text(lastMessage['message'],
                                        style: TextStyle(
                                          color: themeProvider.isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ));
                                  }
                                }
                              } else {
                                return Text('No messages',
                                    style: TextStyle(
                                      color: themeProvider.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ));
                              }
                            },
                          ),
                          leading: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                                friend['profileImage']),
                          ),
                          trailing: Icon(Icons.message),
                        );
                      }
                    },
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromRGBO(58, 150, 255, 1),
        child: Icon(Icons.group, color: Colors.white),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GroupChatHomeScreen(),
          ),
        ),
      ),
    );
  }
}
