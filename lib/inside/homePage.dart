import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

String? postimg;

class _HomePageState extends State<HomePage> {
  final postController = TextEditingController();
  final CollectionReference postsCollection =
      FirebaseFirestore.instance.collection('posts');
  late User? currentUser;

  late BehaviorSubject<DateTime> timeStream =
      BehaviorSubject<DateTime>.seeded(DateTime.now());

  StreamSubscription<QuerySnapshot>? postsSubscription;
  StreamBuilder<QuerySnapshot>? postsStreamBuilder;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeCurrentUser();
    createPostsStreamBuilder();
  }

  @override
  void dispose() {
    postController.dispose();
    timeStream.close();
    postsSubscription?.cancel();
    super.dispose();
  }

  Future<void> initializeCurrentUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      setState(() {
        currentUser = user;
      });
    }
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user?.email)
        .get();

    for (var doc in querySnapshot.docs) {
      setState(() {
        postimg = doc["profileImage"];
      });
    }

    timeStream =
        BehaviorSubject<DateTime>.seeded(DateTime.now()); // Use BehaviorSubject
  }

  void createPostsStreamBuilder() {
    if (postsSubscription != null) {
      return;
    }

    postsSubscription = postsCollection
        .orderBy('postTime', descending: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        postsStreamBuilder = StreamBuilder<QuerySnapshot>(
          stream: Stream.value(snapshot), // Use a new stream instance
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData) {
              return SizedBox();
            }

            List<DocumentSnapshot> posts = snapshot.data!.docs;

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> postData =
                    posts[index].data() as Map<String, dynamic>;
                DateTime postTime = postData['postTime'].toDate();
                String postId = posts[index].id;

                bool isCurrentUserPost = currentUser?.uid == postData['userId'];

                return Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                    title: Row(
                      children: [
                        Text(
                          postData['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Spacer(),
                        if (isCurrentUserPost)
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                // Handle edit post here
                                // You can navigate to an edit screen and pass the postId
                              } else if (value == 'delete') {
                                // Handle delete post here
                                showDeleteConfirmationDialog(postId);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete),
                                    SizedBox(width: 8),
                                    Text('Delete'),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'message') {
                                // Implement the logic for the "Message" option here
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem<String>(
                                value: 'message',
                                child: Row(
                                  children: [
                                    Icon(Icons.message),
                                    SizedBox(width: 8),
                                    Text('Message'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StreamBuilder<DateTime>(
                          stream: timeStream,
                          initialData: DateTime.now(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              String formattedTime = formatPostTime(postTime);
                              return Text(formattedTime);
                            } else {
                              return SizedBox();
                            }
                          },
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          postData['postText'],
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(postData['profileImage']),
                    ),
                  ),
                );
              },
            );
          },
        );
      });
    });
  }

  Future<void> addPost() async {
    String postText = postController.text;
    String? name =
        currentUser?.displayName; // Update to currentUser?.displayName
    DateTime postTime = DateTime.now();

    await postsCollection.add({
      'postText': postText,
      'name': name,
      'profileImage': postimg,
      'postTime': postTime,
      'userId': currentUser?.uid, // Update to currentUser?.uid
    });

    postController.clear();

    setState(() {});
  }

  Future<void> deletePost(String postId) async {
    await postsCollection.doc(postId).delete();
  }

  String formatPostTime(DateTime postTime) {
    final now = DateTime.now();
    final difference = now.difference(postTime);

    if (difference.inDays >= 1) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} hr${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'now';
    }
  }

  void showDeleteConfirmationDialog(String postId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Post'),
          content: Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deletePost(postId);
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Dismiss the keyboard when tapping outside the text field
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Share a Post',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: postController,
                    decoration: InputDecoration(
                      hintText: "What's on your mind...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.all(5),
                        onPressed: () {
                          // Add your onPressed logic here
                        },
                        iconSize: 30,
                        icon: Icon(
                          Icons.image,
                          color: Color.fromRGBO(58, 150, 255, 1),
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: addPost,
                        icon: Icon(
                          Icons.send_rounded,
                          color: Color.fromRGBO(58, 150, 255, 1),
                        ),
                        iconSize: 30,
                        splashColor: Color.fromRGBO(58, 150, 255, 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: postsStreamBuilder ?? Container(),
            ),
          ],
        ),
      ),
    );
  }
}
