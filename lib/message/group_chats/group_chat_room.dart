import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jukto/message/group_chats/group_info.dart';
import 'package:jukto/theme/theme.dart';
import 'package:provider/provider.dart';

class GroupChatRoom extends StatefulWidget {
  final String groupChatId, groupName;

  GroupChatRoom({required this.groupName, required this.groupChatId, Key? key})
      : super(key: key);

  @override
  State<GroupChatRoom> createState() => _GroupChatRoomState();
}

String CurrentPic = ' ';
String name = '';

class _GroupChatRoomState extends State<GroupChatRoom> {
  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchData();
    updateOldImage();
  }

  Future<void> fetchData() async {
    if (_auth.currentUser != null) {
      user = _auth.currentUser;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user?.email)
          .get();

      for (var doc in querySnapshot.docs) {
        setState(() {
          CurrentPic = doc["profileImage"];
          name = doc['name'];
        });
      }
    }
  }

  Future<void> updateOldImage() async {
    String currentemail = _auth.currentUser!.email.toString();
    QuerySnapshot oldMessagesSnapshot = await _firestore
        .collection('groups')
        .doc(widget.groupChatId)
        .collection('chats')
        .where('email', isEqualTo: user!.email)
        .get();

    for (var messageDoc in oldMessagesSnapshot.docs) {
      await messageDoc.reference.update({
        'profileImage': CurrentPic,
        'sendBy': name,
      });
    }
  }

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      String currentEmail = _auth.currentUser!.email.toString();

      QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: currentEmail)
          .get();

      if (userSnapshot.docs.length == 1) {
        DocumentSnapshot userData = userSnapshot.docs.first;
        Map<String, dynamic> userDataMap =
            userData.data() as Map<String, dynamic>;

        // Update the current user's display name in the userData
        userDataMap['sendBy'] = _auth.currentUser!.displayName;

        Map<String, dynamic> chatData = {
          "sendBy": _auth.currentUser!.displayName,
          "profileImage": userDataMap['profileImage'],
          "email": _auth.currentUser!.email,
          "message": _message.text,
          "type": "text",
          "time": FieldValue.serverTimestamp(),
        };

        _message.clear();

        await _firestore
            .collection('groups')
            .doc(widget.groupChatId)
            .collection('chats')
            .add(chatData);

        // Update the profileImage for old messages sent by the current user

        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GroupInfo(
                        groupName: widget.groupName,
                        groupId: widget.groupChatId,
                        memberpic: CurrentPic,
                        membername: name,
                      ),
                    ),
                  ),
              icon: Icon(Icons.more_vert)),
        ],
        backgroundColor: const Color.fromRGBO(58, 150, 255, 1),
        iconTheme: IconThemeData(color: Colors.white, size: 35.0),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Container(
              height: size.height / 1.27,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('groups')
                    .doc(widget.groupChatId)
                    .collection('chats')
                    .orderBy('time')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (snapshot.data!.docs.length > 0) {
                        scrollController.animateTo(
                          scrollController.position.maxScrollExtent,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    });
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> chatMap =
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;

                        return messageTile(size, chatMap);
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Container(
              height: size.height / 10,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 12,
                width: size.width / 1.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: size.height / 15,
                      width: size.width / 1.3,
                      child: TextField(
                        style: TextStyle(
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                        controller: _message,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.photo,
                                color: Color.fromRGBO(58, 150, 255, 1),
                              ),
                            ),
                            hintText: "Send Message",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            )),
                      ),
                    ),
                    IconButton(
                        icon: Icon(Icons.send,
                            color: Color.fromRGBO(58, 150, 255, 1)),
                        onPressed: onSendMessage),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget messageTile(Size size, Map<String, dynamic> chatMap) {
    return Builder(builder: (_) {
      if (chatMap['type'] == "text") {
        return Container(
          margin: EdgeInsets.only(top: 10),
          width: size.width,
          alignment: chatMap['email'] == _auth.currentUser!.email
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: chatMap['email'] == _auth.currentUser!.email
                ? MainAxisAlignment.end // Align to the right if current user
                : MainAxisAlignment.start, // Align to the left if other user
            children: [
              if (chatMap['email'] != _auth.currentUser!.email)
                CircleAvatar(
                  radius: 18,
                  backgroundImage: chatMap['email'] == _auth.currentUser!.email
                      ? null
                      : (chatMap['profileImage'] != null
                          ? NetworkImage(chatMap['profileImage'])
                          : null),
                ),
              Column(
                crossAxisAlignment: chatMap['email'] == _auth.currentUser!.email
                    ? CrossAxisAlignment
                        .end // Align to the right if current user
                    : CrossAxisAlignment
                        .start, // Align to the left if other user
                children: [
                  if (chatMap['email'] != _auth.currentUser!.email)
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                      child: Text(
                        chatMap['sendBy'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                    margin: EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    decoration: chatMap['email'] == _auth.currentUser!.email
                        ? BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                                topRight: Radius.circular(10)),
                            color: Colors.grey,
                          )
                        : BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                                topLeft: Radius.circular(10)),
                            color: Color.fromRGBO(58, 150, 255, 1),
                          ),
                    child: Text(
                      chatMap['message'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
      if (chatMap['type'] == "img") {
        return Container(
          width: size.width,
          alignment: chatMap['email'] == _auth.currentUser!.email
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            height: size.height / 2,
            child: Image.network(
              chatMap['message'],
            ),
          ),
        );
      }

      if (chatMap['type'] == "notify") {
        print(chatMap['message']);
        return Container(
          width: size.width,
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.black38,
            ),
            child: Text(
              chatMap['message'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      } else {
        return SizedBox();
      }
    });
  }
}
