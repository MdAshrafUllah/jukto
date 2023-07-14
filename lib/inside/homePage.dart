import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

String? postimg;
String? selectimg;

class Post {
  final String postId;
  final String postText;
  final String name;
  final String profileImage;
  final DateTime postTime;
  final String userId;
  bool isLiked;
  int likeCount;
  int commentCount;
  List<Comment> comments = [];
  bool showComments = false;
  String? imageUrl;

  Post({
    required this.postId,
    required this.postText,
    required this.name,
    required this.profileImage,
    required this.postTime,
    required this.userId,
    this.isLiked = false,
    this.likeCount = 0,
    this.commentCount = 0,
    required List<Comment> comments,
    this.imageUrl,
  });

  List<String> get likes =>
      comments.map((comment) => comment.commentId).toList();
}

class Comment {
  final String commentId;
  final String commentText;
  final String commenterName;
  final String commenterProfileImage;

  Comment({
    required this.commentId,
    required this.commentText,
    required this.commenterName,
    required this.commenterProfileImage,
  });
}

class _HomePageState extends State<HomePage> {
  final postController = TextEditingController();
  final commentController = TextEditingController();
  final CollectionReference postsCollection =
      FirebaseFirestore.instance.collection('posts');
  late User? currentUser;
  List<Post> posts = [];

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
    commentController.dispose();
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

    timeStream = BehaviorSubject<DateTime>.seeded(DateTime.now());
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
        posts = snapshot.docs.map((doc) {
          Map<String, dynamic> postData = doc.data() as Map<String, dynamic>;
          DateTime postTime = postData['postTime'].toDate();
          String postId = doc.id;
          bool isCurrentUserPost = currentUser?.uid == postData['userId'];

          int commentCount = postData['commentCount'] ?? 0;

          List<Comment> comments = [];
          if (postData['comments'] != null) {
            List<dynamic> commentData = postData['comments'];
            comments = commentData.map((comment) {
              return Comment(
                commentId: comment['commentId'],
                commentText: comment['commentText'],
                commenterName: comment['commenterName'],
                commenterProfileImage: comment['commenterProfileImage'],
              );
            }).toList();
          }

          bool isLiked = false;
          if (postData['likes'] != null) {
            List<dynamic> likesData = postData['likes'];
            isLiked = likesData.contains(currentUser?.uid);
          }

          return Post(
            postId: postId,
            postText: postData['postText'],
            name: postData['name'],
            profileImage: postData['profileImage'],
            postTime: postTime,
            userId: postData['userId'],
            isLiked: isLiked,
            likeCount: postData['likeCount'] ?? 0,
            commentCount: commentCount,
            comments: comments,
            imageUrl: postData['imageUrl'],
          );
        }).toList();
      });
    });
  }

  Future<void> addPost() async {
    String postText = postController.text;
    String? name = currentUser?.displayName;
    DateTime postTime = DateTime.now();

    // Upload the image to Firebase Storage if an image is selected
    String? imageUrl;
    if (selectimg != null) {
      Reference storageReference =
          FirebaseStorage.instance.ref().child('posts/${DateTime.now()}.jpg');
      UploadTask uploadTask = storageReference.putFile(File(selectimg!));
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

      // Get the download URL of the uploaded image
      imageUrl = await storageReference.getDownloadURL();
    }

    if (selectimg != null || postText.isNotEmpty) {
      await postsCollection.add({
        'imageUrl': imageUrl,
        'postText': postText,
        'name': name,
        'profileImage': postimg,
        'postTime': postTime,
        'userId': currentUser?.uid,
        'likeCount': 0,
        'commentCount': 0,
        'comments': [],
        'likes': [],
      });
      setState(() {
        selectimg = null;
      });
    }

    postController.clear();

    setState(() {});
  }

  Future<void> deletePost(String postId) async {
    DocumentSnapshot postSnapshot = await postsCollection.doc(postId).get();
    if (postSnapshot.exists) {
      await postsCollection.doc(postId).delete();

      CollectionReference commentsCollection =
          postsCollection.doc(postId).collection('comments');
      QuerySnapshot commentsSnapshot = await commentsCollection.get();
      commentsSnapshot.docs.forEach((commentDoc) {
        commentDoc.reference.delete();
      });
    }
  }

  Future<void> addComment(Post post) async {
    String commentText = commentController.text;
    String? commenterName = currentUser?.displayName;
    String? commenterProfileImage = postimg;

    DocumentReference commentRef =
        postsCollection.doc(post.postId).collection('comments').doc();

    await commentRef.set({
      'commentId': commentRef.id,
      'commentText': commentText,
      'commenterName': commenterName,
      'commenterProfileImage': commenterProfileImage,
    });

    await postsCollection.doc(post.postId).update({
      'commentCount': FieldValue.increment(1),
    });

    setState(() {
      Comment newComment = Comment(
        commentId: commentRef.id,
        commentText: commentText,
        commenterName: commenterName ?? '',
        commenterProfileImage: commenterProfileImage ?? '',
      );
      post.comments.add(newComment);
      post.commentCount++;
    });

    commentController.clear();
  }

  Future<void> deleteComment(Post post, Comment comment) async {
    DocumentReference commentRef = postsCollection
        .doc(post.postId)
        .collection('comments')
        .doc(comment.commentId);
    await commentRef.delete();

    await postsCollection.doc(post.postId).update({
      'commentCount': FieldValue.increment(-1),
    });

    setState(() {
      post.comments.remove(comment);
      post.commentCount--;
    });
  }

  Future<void> toggleLike(Post post) async {
    String userId = currentUser?.uid ?? '';

    if (post.isLiked) {
      await postsCollection.doc(post.postId).update({
        'likeCount': FieldValue.increment(-1),
        'likes': FieldValue.arrayRemove([userId]),
      });
    } else {
      await postsCollection.doc(post.postId).update({
        'likeCount': FieldValue.increment(1),
        'likes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  Future<void> toggleComments(Post post) async {
    if (post.showComments) {
      QuerySnapshot commentsSnapshot =
          await postsCollection.doc(post.postId).collection('comments').get();

      List<Comment> comments = commentsSnapshot.docs.map((commentDoc) {
        Map<String, dynamic> commentData =
            commentDoc.data() as Map<String, dynamic>;

        return Comment(
          commentId: commentData['commentId'],
          commentText: commentData['commentText'],
          commenterName: commentData['commenterName'],
          commenterProfileImage: commentData['commenterProfileImage'],
        );
      }).toList();

      setState(() {
        post.comments = comments;
      });
    }
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
          title: Text('Delete Post',
              style: TextStyle(
                  color: Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.white
                      : Colors.black)),
          content: Text('Are you sure you want to delete this post?',
              style: TextStyle(
                  color: Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.white
                      : Colors.black)),
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

  Future<List<Comment>> fetchComments(String postId) async {
    CollectionReference commentsCollection =
        postsCollection.doc(postId).collection('comments');
    QuerySnapshot commentsSnapshot = await commentsCollection.get();

    List<Comment> comments = commentsSnapshot.docs.map((commentDoc) {
      Map<String, dynamic> commentData =
          commentDoc.data() as Map<String, dynamic>;

      return Comment(
        commentId: commentData['commentId'],
        commentText: commentData['commentText'],
        commenterName: commentData['commenterName'],
        commenterProfileImage: commentData['commenterProfileImage'],
      );
    }).toList();

    return comments;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? Colors.black54
                    : Colors.blueGrey[50],
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
                  SizedBox(height: 10),
                  TextField(
                    style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black),
                    controller: postController,
                    decoration: InputDecoration(
                      hintText: "What's on your mind...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: selectimg != null
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  selectimg = null;
                                });
                              },
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.red,
                              ))
                          : IconButton(
                              padding: EdgeInsets.all(5),
                              onPressed: () async {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles(
                                  type: FileType.image,
                                  allowMultiple: false,
                                );

                                if (result != null && result.files.isNotEmpty) {
                                  File file = File(result.files.first.path!);
                                  setState(() {
                                    selectimg = file.path;
                                  });
                                }
                              },
                              icon: Icon(
                                Icons.image,
                                color: Color.fromRGBO(58, 150, 255, 1),
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: addPost,
                      icon: Icon(
                        Icons.send_rounded,
                        color: Color.fromRGBO(58, 150, 255, 1),
                      ),
                      iconSize: 30,
                      splashColor: Color.fromRGBO(58, 150, 255, 1),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  Post post = posts[index];
                  return Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? Colors.black54
                          : Colors.blueGrey[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                      title: Row(
                        children: [
                          Text(
                            post.name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black),
                          ),
                          Spacer(),
                          if (currentUser?.uid == post.userId)
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit_post') {
                                  // Handle edit post here
                                  // You can navigate to an edit screen and pass the postId
                                } else if (value == 'delete_post') {
                                  showDeleteConfirmationDialog(post.postId);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem<String>(
                                  value: 'edit_post',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 8),
                                      Text(
                                        'Edit post',
                                        style: TextStyle(
                                            color: themeProvider.isDarkMode
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  value: 'delete_post',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete),
                                      SizedBox(width: 8),
                                      Text('Delete',
                                          style: TextStyle(
                                              color: themeProvider.isDarkMode
                                                  ? Colors.white
                                                  : Colors.black)),
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
                                      Text('Message',
                                          style: TextStyle(
                                              color: themeProvider.isDarkMode
                                                  ? Colors.white
                                                  : Colors.black)),
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
                                String formattedTime =
                                    formatPostTime(post.postTime);
                                return Text(formattedTime,
                                    style: TextStyle(
                                        color: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.black));
                              } else {
                                return SizedBox();
                              }
                            },
                          ),
                          SizedBox(height: 15),
                          Text(
                            post.postText,
                            style: TextStyle(
                                fontSize: 18,
                                color: themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black),
                          ),
                          if (post.imageUrl != null)
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullScreenImagePage(
                                      imageUrl: post.imageUrl,
                                    ),
                                  ),
                                );
                              },
                              child: Image.network(
                                post.imageUrl!,
                                fit: BoxFit.cover,
                                height: 200,
                                width: double.infinity,
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      toggleLike(post);
                                    },
                                    icon: Icon(
                                      post.isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: post.isLiked ? Colors.red : null,
                                    ),
                                  ),
                                  Text('${post.likeCount}',
                                      style: TextStyle(
                                          color: themeProvider.isDarkMode
                                              ? Colors.white
                                              : Colors.black)),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        post.showComments = !post.showComments;
                                        toggleComments(post);
                                      });
                                    },
                                    icon: Icon(
                                      Icons.comment,
                                      color: Color.fromRGBO(58, 150, 255, 1),
                                    ),
                                  ),
                                  Text('${post.commentCount}',
                                      style: TextStyle(
                                          color: themeProvider.isDarkMode
                                              ? Colors.white
                                              : Colors.black)),
                                ],
                              ),
                            ],
                          ),
                          if (post.showComments)
                            Column(
                              children: [
                                Divider(),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: post.comments.length,
                                  itemBuilder: (context, commentIndex) {
                                    Comment comment =
                                        post.comments[commentIndex];

                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            comment.commenterProfileImage),
                                      ),
                                      title: Row(children: [
                                        Text(comment.commenterName,
                                            style: TextStyle(
                                                color: themeProvider.isDarkMode
                                                    ? Colors.white
                                                    : Colors.black)),
                                        Spacer(),
                                        if (currentUser?.displayName ==
                                            comment.commenterName)
                                          PopupMenuButton<String>(
                                            onSelected: (value) {
                                              if (value == 'edit_comment') {
                                                // Handle edit post here
                                                // You can navigate to an edit screen and pass the postId
                                              } else if (value ==
                                                  'delete_comment') {
                                                showDeleteConfirmationDialog(
                                                    post.postId);
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              PopupMenuItem<String>(
                                                value: 'edit_comment',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit),
                                                    SizedBox(width: 8),
                                                    Text('Edit',
                                                        style: TextStyle(
                                                            color: themeProvider
                                                                    .isDarkMode
                                                                ? Colors.white
                                                                : Colors
                                                                    .black)),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem<String>(
                                                value: 'delete_comment',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete),
                                                    SizedBox(width: 8),
                                                    Text('Delete',
                                                        style: TextStyle(
                                                            color: themeProvider
                                                                    .isDarkMode
                                                                ? Colors.white
                                                                : Colors
                                                                    .black)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        else if (currentUser?.uid ==
                                            post.userId)
                                          PopupMenuButton<String>(
                                            onSelected: (value) {
                                              if (value == 'message') {
                                                // Handle edit post here
                                                // You can navigate to an edit screen and pass the postId
                                              } else if (value == 'message') {
                                                showDeleteConfirmationDialog(
                                                    post.postId);
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              PopupMenuItem<String>(
                                                value: 'message',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.message),
                                                    SizedBox(width: 8),
                                                    Text('message',
                                                        style: TextStyle(
                                                            color: themeProvider
                                                                    .isDarkMode
                                                                ? Colors.white
                                                                : Colors
                                                                    .black)),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem<String>(
                                                value: 'delete_comment',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete),
                                                    SizedBox(width: 8),
                                                    Text('Delete',
                                                        style: TextStyle(
                                                            color: themeProvider
                                                                    .isDarkMode
                                                                ? Colors.white
                                                                : Colors
                                                                    .black)),
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
                                                    Text('Message',
                                                        style: TextStyle(
                                                            color: themeProvider
                                                                    .isDarkMode
                                                                ? Colors.white
                                                                : Colors
                                                                    .black)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                      ]),
                                      subtitle: Text(comment.commentText,
                                          style: TextStyle(
                                              color: themeProvider.isDarkMode
                                                  ? Colors.white
                                                  : Colors.black)),
                                    );
                                  },
                                ),
                                TextField(
                                    controller: commentController,
                                    decoration: InputDecoration(
                                      hintText: 'Add a comment...',
                                      border: OutlineInputBorder(),
                                    ),
                                    style: TextStyle(
                                        color: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.black)),
                                ElevatedButton(
                                  onPressed: () {
                                    if (commentController.text.isNotEmpty) {
                                      addComment(post);
                                    }
                                  },
                                  child: Text('Add Comment'),
                                ),
                              ],
                            ),
                        ],
                      ),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(post.profileImage),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String? imageUrl;

  const FullScreenImagePage({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Jukto",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 150, 255, 1),
        iconTheme: IconThemeData(color: Colors.white, size: 35.0),
      ),
      body: Center(
        child: Container(
            child: Image.network(
              imageUrl!,
              fit: BoxFit.contain,
              height: double.infinity,
              width: double.infinity,
            ),
            color: themeProvider.isDarkMode ? Colors.white : Colors.black),
      ),
    );
  }
}
