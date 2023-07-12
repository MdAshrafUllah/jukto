import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  late User currentUser;

  late Stream<DateTime> timeStream;

  StreamBuilder<QuerySnapshot>? postsStreamBuilder; // Add this line

  @override
  void initState() {
    super.initState();
    initializeCurrentUser();
    createPostsStreamBuilder(); // Add this line
  }

  @override
  void dispose() {
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
        Stream<DateTime>.periodic(Duration(seconds: 1), (_) => DateTime.now());
  }

  void createPostsStreamBuilder() {
    postsStreamBuilder = StreamBuilder<QuerySnapshot>(
      stream: postsCollection.orderBy('postTime', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        List<DocumentSnapshot> posts = snapshot.data!.docs;

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> postData =
                posts[index].data() as Map<String, dynamic>;
            DateTime postTime = postData['postTime'].toDate();

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
                      postData['userName'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Spacer(),
                    // IconButton(onPressed: () {}, icon: Icon(Icons.more_horiz))
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
                          DateTime currentTime = snapshot.data!;
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
  }

  Future<void> addPost() async {
    String postText = postController.text;
    String? userName = currentUser.displayName;
    DateTime postTime = DateTime.now();

    await postsCollection.add({
      'postText': postText,
      'userName': userName,
      'profileImage': postimg,
      'postTime': postTime,
    });

    postController.clear();
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        body: Column(
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
              child: postsStreamBuilder ??
                  Container(), // Use the created StreamBuilder
            ),
          ],
        ),
      ),
    );
  }
}
