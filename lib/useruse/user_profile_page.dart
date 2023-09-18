// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jukto/theme/theme.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

class UserProfilePage extends StatefulWidget {
  final String profileImage;
  final String name;
  final String email;
  final String bio;
  final String university;
  final String city;

  const UserProfilePage({
    Key? key,
    required this.profileImage,
    required this.name,
    required this.email,
    required this.bio,
    required this.university,
    required this.city,
  }) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  String userID = '';
  bool isFriend = false;
  bool sentRequest = false;
  bool receivedRequest = false;
  String name = '';
  String email = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize the user variable before calling checkFriendshipStatus()
    user = auth.currentUser;
    fetchData();
    if (user != null) {
      checkFriendshipStatus().then((result) {
        setState(() {
          isFriend = result['isFriend']!;
          receivedRequest = result['receivedRequest']!;
          sentRequest = result['sentRequest']!;
        });
      });
    }
  }

  Future<void> fetchData() async {
    if (auth.currentUser != null) {
      user = auth.currentUser;
      userID = user!.uid; // Update the userID here
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user?.email)
          .get();

      for (var doc in querySnapshot.docs) {
        setState(() {
          email = doc['email'];
          name = doc['name'];
        });
      }
    }
  }

  Future<Map<String, bool>> checkFriendshipStatus() async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user!.email)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      var userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
      var friends = userData['friends'] as List<dynamic>?;
      var friendRequest = userData['friendRequest'] as List<dynamic>?;
      var sentrequest = userData['sentRequest'] as List<dynamic>?;

      // Remove the redeclarations here and directly use the class variables
      isFriend = false;
      receivedRequest = false;
      sentRequest = false;

      if (friends != null) {
        isFriend = friends.any((friend) => friend['email'] == widget.email);
      }

      if (friendRequest != null) {
        receivedRequest =
            friendRequest.any((friend) => friend['email'] == widget.email);
      }

      if (sentrequest != null) {
        sentRequest =
            sentrequest.any((friend) => friend['email'] == widget.email);
      }

      return {
        'isFriend': isFriend,
        'receivedRequest': receivedRequest,
        'sentRequest': sentRequest,
      };
    }

    return {
      'isFriend': false,
      'receivedRequest': false,
      'sentRequest': false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;
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
        iconTheme: const IconThemeData(color: Colors.white, size: 35.0),
      ),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ShowImage(
                      imageUrl: widget.profileImage,
                    ),
                  ),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      CachedNetworkImageProvider(widget.profileImage),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  widget.bio,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                margin: EdgeInsets.only(
                    left: size.width / 18, right: size.width / 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SingleChildScrollView(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'University: ',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.university,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          'From: ',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.city,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (isFriend == true)
                Center(
                  child: Container(
                    height: 50,
                    width: 120,
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(5)),
                    child: const Center(
                      child: Text(
                        "Friend",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          // You can customize the style here
                        ),
                      ),
                    ),
                  ),
                )
              else if (receivedRequest == true)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                        });
                        await FirebaseFirestore.instance
                            .collection('users')
                            .where('email', isEqualTo: email)
                            .get()
                            .then((QuerySnapshot querySnapshot) {
                          for (var doc in querySnapshot.docs) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(doc.id)
                                .update({
                              'friends': FieldValue.arrayUnion([
                                {
                                  'name': widget.name,
                                  'email': widget.email,
                                }
                              ]),
                              'friendRequest': FieldValue.arrayRemove([
                                {
                                  'name': widget.name,
                                  'email': widget.email,
                                }
                              ])
                            });
                          }
                        });

                        await FirebaseFirestore.instance
                            .collection('users')
                            .where('email', isEqualTo: widget.email)
                            .get()
                            .then((QuerySnapshot querySnapshot) {
                          for (var doc in querySnapshot.docs) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(doc.id)
                                .update({
                              'friends': FieldValue.arrayUnion([
                                {
                                  'name': name,
                                  'email': email,
                                }
                              ]),
                              'sentRequest': FieldValue.arrayRemove([
                                {
                                  'name': name,
                                  'email': email,
                                }
                              ])
                            });
                          }
                        });

                        await checkFriendshipStatus().then((result) {
                          setState(() {
                            isFriend = result['isFriend']!;
                            receivedRequest = result['receivedRequest']!;
                            sentRequest = result['sentRequest']!;
                          });
                        });
                        setState(() {
                          isLoading = false;
                        });

                        await fetchData();

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green,
                            content: Text(
                              '${widget.name} is Now your Friend',
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Roboto',
                              ),
                            )));
                      },
                      child: Container(
                        height: 50,
                        width: 120,
                        decoration: BoxDecoration(
                            color: const Color.fromRGBO(58, 150, 255, 1),
                            borderRadius: BorderRadius.circular(5)),
                        child: const Center(
                          child: Text(
                            "Confirm",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              // You can customize the style here
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                        });
                        await FirebaseFirestore.instance
                            .collection('users')
                            .where('email', isEqualTo: email)
                            .get()
                            .then((QuerySnapshot querySnapshot) {
                          for (var doc in querySnapshot.docs) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(doc.id)
                                .update({
                              'friendRequest': FieldValue.arrayRemove([
                                {
                                  'name': widget.name,
                                  'email': widget.email,
                                }
                              ])
                            });
                          }
                        });

                        await FirebaseFirestore.instance
                            .collection('users')
                            .where('email', isEqualTo: widget.email)
                            .get()
                            .then((QuerySnapshot querySnapshot) {
                          for (var doc in querySnapshot.docs) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(doc.id)
                                .update({
                              'sentRequest': FieldValue.arrayRemove([
                                {
                                  'name': name,
                                  'email': email,
                                }
                              ])
                            });
                          }
                        });
                        await checkFriendshipStatus().then((result) {
                          setState(() {
                            isFriend = result['isFriend']!;
                            receivedRequest = result['receivedRequest']!;
                            sentRequest = result['sentRequest']!;
                          });
                        });
                        setState(() {
                          isLoading = false;
                        });
                        await fetchData();
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.redAccent,
                                content: Text(
                                  'Friend Request Cancel',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Roboto',
                                  ),
                                )));
                      },
                      child: Container(
                        height: 50,
                        width: 120,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(5)),
                        child: const Center(
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              // You can customize the style here
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              else if (sentRequest == true)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 50,
                      width: 130,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(5)),
                      child: const Center(
                        child: Text(
                          "Request Sent",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            // You can customize the style here
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                        });
                        await FirebaseFirestore.instance
                            .collection('users')
                            .where('email', isEqualTo: email)
                            .get()
                            .then((QuerySnapshot querySnapshot) {
                          for (var doc in querySnapshot.docs) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(doc.id)
                                .update({
                              'sentRequest': FieldValue.arrayRemove([
                                {
                                  'name': widget.name,
                                  'email': widget.email,
                                }
                              ])
                            });
                          }
                        });

                        await FirebaseFirestore.instance
                            .collection('users')
                            .where('email', isEqualTo: widget.email)
                            .get()
                            .then((QuerySnapshot querySnapshot) {
                          for (var doc in querySnapshot.docs) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(doc.id)
                                .update({
                              'friendRequest': FieldValue.arrayRemove([
                                {
                                  'name': name,
                                  'email': email,
                                }
                              ])
                            });
                          }
                        });

                        await checkFriendshipStatus().then((result) {
                          setState(() {
                            isFriend = result['isFriend']!;
                            receivedRequest = result['receivedRequest']!;
                            sentRequest = result['sentRequest']!;
                          });
                        });
                        setState(() {
                          isLoading = false;
                        });
                        await fetchData();

                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.redAccent,
                                content: Text(
                                  'Friend Request Cancel',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Roboto',
                                  ),
                                )));
                      },
                      child: Container(
                        height: 50,
                        width: 120,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(5)),
                        child: const Center(
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              // You can customize the style here
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              else
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      isLoading = true;
                    });
                    await FirebaseFirestore.instance
                        .collection('users')
                        .where('email', isEqualTo: widget.email)
                        .get()
                        .then((QuerySnapshot querySnapshot) {
                      for (var doc in querySnapshot.docs) {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(doc.id)
                            .update({
                          'friendRequest': FieldValue.arrayUnion([
                            {
                              'name': name,
                              'email': email,
                            }
                          ])
                        });
                      }
                    });
                    await FirebaseFirestore.instance
                        .collection('users')
                        .where('email', isEqualTo: email)
                        .get()
                        .then((QuerySnapshot querySnapshot) {
                      for (var doc in querySnapshot.docs) {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(doc.id)
                            .update({
                          'sentRequest': FieldValue.arrayUnion([
                            {'name': widget.name, 'email': widget.email}
                          ])
                        });
                      }
                    });
                    await checkFriendshipStatus().then((result) {
                      setState(() {
                        isFriend = result['isFriend']!;
                        receivedRequest = result['receivedRequest']!;
                        sentRequest = result['sentRequest']!;
                      });
                    });

                    setState(() {
                      isLoading = false;
                    });

                    await fetchData();

                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.green,
                        content: Text(
                          'Friend Request Sent',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Roboto',
                          ),
                        )));
                  },
                  child: Container(
                    height: 50,
                    width: 130,
                    decoration: BoxDecoration(
                        color: const Color.fromRGBO(58, 150, 255, 1),
                        borderRadius: BorderRadius.circular(5)),
                    child: const Center(
                      child: Text(
                        "Add Friend",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          // You can customize the style here
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: CachedNetworkImage(imageUrl: imageUrl),
      ),
    );
  }
}
