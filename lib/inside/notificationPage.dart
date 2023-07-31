import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jukto/theme/theme.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class UserModel {
  final String name;
  final String profileImageUrl;

  UserModel({
    required this.name,
    required this.profileImageUrl,
  });
}

class CommenterModel {
  final String name;
  final String profileImageUrl;

  CommenterModel({required this.name, required this.profileImageUrl});
}

class _NotificationPageState extends State<NotificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String _userID = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (_auth.currentUser != null) {
      _user = _auth.currentUser;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _user?.email)
          .get();

      querySnapshot.docs.forEach((doc) {
        final documentId = doc.id;
        setState(() {
          _userID = documentId;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: _user?.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var userData =
                snapshot.data?.docs.first.data() as Map<String, dynamic>;
            var friendRequests = userData['friendRequest'] as List<dynamic>?;

            return Column(
              children: [
                Visibility(
                  visible: friendRequests != null && friendRequests.isNotEmpty,
                  child: SizedBox(
                    height: 100,
                    child: ListView.builder(
                      itemCount: friendRequests?.length ?? 0,
                      itemBuilder: (context, index) {
                        var friendRequest =
                            friendRequests![index] as Map<String, dynamic>;
                        var friendEmail = friendRequest['email'];

                        return StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .where('email', isEqualTo: friendEmail)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                var friendData = snapshot.data?.docs.first
                                    .data() as Map<String, dynamic>;

                                return Card(
                                  color: themeProvider.isDarkMode
                                      ? Colors.black54
                                      : Colors.white,
                                  child: ListTile(
                                    title: Text(
                                      '${friendData['name']} Sent you a Friend Request',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(_userID)
                                                .update({
                                              'friends': FieldValue.arrayUnion([
                                                {
                                                  'name': friendData['name'],
                                                  'email': friendData['email'],
                                                }
                                              ]),
                                              'friendRequest':
                                                  FieldValue.arrayRemove([
                                                {
                                                  'name': friendData['name'],
                                                  'email': friendData['email'],
                                                }
                                              ])
                                            });

                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .where('email',
                                                    isEqualTo:
                                                        friendData['email'])
                                                .get()
                                                .then((QuerySnapshot
                                                    querySnapshot) {
                                              querySnapshot.docs.forEach((doc) {
                                                FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(doc.id)
                                                    .update({
                                                  'friends':
                                                      FieldValue.arrayUnion([
                                                    {
                                                      'name':
                                                          _user?.displayName,
                                                      'email': _user?.email,
                                                    }
                                                  ]),
                                                  'sentRequest':
                                                      FieldValue.arrayRemove([
                                                    {
                                                      'name':
                                                          _user?.displayName,
                                                      'email': _user?.email,
                                                    }
                                                  ])
                                                });
                                              });
                                            });
                                          },
                                          child: Text('Accept'),
                                        ),
                                        SizedBox(width: 8),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          onPressed: () async {
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(_userID)
                                                .update({
                                              'friendRequest':
                                                  FieldValue.arrayRemove([
                                                {
                                                  'name': friendData['name'],
                                                  'email': friendData['email'],
                                                }
                                              ])
                                            });

                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .where('email',
                                                    isEqualTo:
                                                        friendData['email'])
                                                .get()
                                                .then((QuerySnapshot
                                                    querySnapshot) {
                                              querySnapshot.docs.forEach((doc) {
                                                FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(doc.id)
                                                    .update({
                                                  'sentRequest':
                                                      FieldValue.arrayRemove([
                                                    {
                                                      'name':
                                                          _user?.displayName,
                                                      'email': _user?.email,
                                                    }
                                                  ])
                                                });
                                              });
                                            });
                                          },
                                          child: Text('Cancel'),
                                        ),
                                      ],
                                    ),
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              friendData['profileImage'] ??
                                                  ' '),
                                    ),
                                  ),
                                );
                              }
                            });
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 300,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text("Error: ${snapshot.error}"),
                        );
                      }

                      final querySnapshot = snapshot.data;

                      return ListView.builder(
                        itemCount: querySnapshot?.docs.length,
                        itemBuilder: (context, index) {
                          final doc = querySnapshot?.docs[index];
                          if (doc!["userId"] == _user?.uid) {
                            final postId = doc.id;
                            final likesList =
                                (doc["likes"] as List).cast<String>();

                            return _buildPostWidgets(postId, likesList);
                          } else {
                            return Container();
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  FutureBuilder<List<UserModel>> _buildPostWidgets(
    String postId,
    List<String> likesList,
  ) {
    return FutureBuilder<List<UserModel>>(
      future: fetchLikedUsersData(likesList, _user?.email ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Text("Error: Unable to fetch user data.");
        }

        final likedUsersData = snapshot.data!;

        return FutureBuilder<List<CommenterModel>>(
          future: fetchCommentersData(postId, _user?.email ?? ''),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError || snapshot.data == null) {
              return Text("Error: Unable to fetch comment data.");
            }

            final commentersData = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Liked users data
                Card(
                  color: Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.black54
                      : Colors.white,
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: likedUsersData.length,
                        itemBuilder: (context, index) {
                          final user = likedUsersData[index];
                          return ListTile(
                            title: Text('${user.name} Liked Your Post',
                                style: TextStyle(
                                  color: Provider.of<ThemeProvider>(context)
                                          .isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                )),
                            leading: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                user.profileImageUrl,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Commenters data
                Card(
                  color: Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.black54
                      : Colors.grey[50],
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: commentersData.length,
                        itemBuilder: (context, index) {
                          final commenterData = commentersData[index];
                          return ListTile(
                            title: Text(
                                '${commenterData.name} Commented on Your Post',
                                style: TextStyle(
                                  color: Provider.of<ThemeProvider>(context)
                                          .isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                )),
                            leading: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                commenterData.profileImageUrl,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

Future<List<UserModel>> fetchLikedUsersData(
    List<dynamic> likesList, String currentUserEmail) async {
  final usersData = <UserModel>[];

  try {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', whereIn: likesList)
        .get();

    userSnapshot.docs.forEach((userDoc) {
      final userData = userDoc.data();
      final userName = userData['name'] as String;
      final profileImageUrl = userData['profileImage'] as String;
      final userEmail = userData['email'] as String;

      if (userEmail != currentUserEmail) {
        usersData
            .add(UserModel(name: userName, profileImageUrl: profileImageUrl));
      }
    });
  } catch (error) {
    print("Error fetching user data: $error");
  }

  return usersData;
}

Future<List<CommenterModel>> fetchCommentersData(
    String postId, String currentUserEmail) async {
  final commentersData = <CommenterModel>[];

  try {
    final commentsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .get();

    commentersData.addAll(commentsSnapshot.docs.map((commentDoc) {
      final commentData = commentDoc.data();
      final commenterName = commentData['commenterName'] as String;
      final commenterProfileImageUrl =
          commentData['commenterProfileImage'] as String;
      if (commentData['commenterEmail'] != currentUserEmail) {
        return CommenterModel(
          name: commenterName,
          profileImageUrl: commenterProfileImageUrl,
        );
      }
      return null;
    }).whereType<CommenterModel>());
  } catch (error) {
    print("Error fetching commenters' data: $error");
  }

  return commentersData;
}
