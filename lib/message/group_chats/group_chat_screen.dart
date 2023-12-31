import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jukto/message/group_chats/create_group/add_members.dart';
import 'package:jukto/message/group_chats/group_chat_room.dart';
import 'package:jukto/theme/theme.dart';
import 'package:provider/provider.dart';

class GroupChatHomeScreen extends StatefulWidget {
  const GroupChatHomeScreen({Key? key}) : super(key: key);

  @override
  GroupChatHomeScreenState createState() => GroupChatHomeScreenState();
}

class GroupChatHomeScreenState extends State<GroupChatHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;

  List groupList = [];

  @override
  void initState() {
    super.initState();
    getAvailableGroups();
  }

  void getAvailableGroups() async {
    String uid = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .where('uid', isEqualTo: uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(doc.id)
            .collection('groups')
            .get()
            .then((value) {
          setState(() {
            groupList = value.docs;
            isLoading = false;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Groups"),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 150, 255, 1),
        iconTheme: const IconThemeData(color: Colors.white, size: 35.0),
      ),
      body: isLoading
          ? Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : RefreshIndicator(
              color: const Color.fromRGBO(58, 150, 255, 1),
              onRefresh: () {
                getAvailableGroups();
                return Future<void>.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                itemCount: groupList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GroupChatRoom(
                          groupName: groupList[index]['name'],
                          groupChatId: groupList[index]['id'],
                        ),
                      ),
                    ),
                    leading: const Icon(Icons.group),
                    title: Text(
                      groupList[index]['name'],
                      style: TextStyle(
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(58, 150, 255, 1),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const AddMembersInGroup(),
          ),
        ),
        tooltip: "Create Group",
        child: const Icon(
          Icons.create,
          color: Colors.white,
        ),
      ),
    );
  }
}
