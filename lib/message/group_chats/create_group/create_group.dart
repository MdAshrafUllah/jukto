import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jukto/inside/welcomePage.dart';
import 'package:jukto/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreateGroup extends StatefulWidget {
  final List<Map<String, dynamic>> membersList;

  const CreateGroup({required this.membersList, Key? key}) : super(key: key);

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final TextEditingController _groupName = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  void createGroup() async {
    setState(() {
      isLoading = true;
    });

    String groupId = Uuid().v1();

    await _firestore.collection('groups').doc(groupId).set({
      "members": widget.membersList,
      "id": groupId,
      "name": _groupName.text,
    });

    for (int i = 0; i < widget.membersList.length; i++) {
      String uid = widget.membersList[i]['uid'];

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
              .doc(groupId)
              .set({
            "name": _groupName.text,
            "id": groupId,
          });
        });
      });
    }

    await _firestore.collection('groups').doc(groupId).collection('chats').add({
      "message": "${_auth.currentUser!.displayName} Created This Group.",
      "type": "notify",
    });

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => welcomePage()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Group Name"),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 150, 255, 1),
        iconTheme: IconThemeData(color: Colors.white, size: 35.0),
      ),
      body: isLoading
          ? Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                SizedBox(
                  height: size.height / 10,
                ),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  padding: EdgeInsets.only(left: 20, right: 20),
                  height: size.height / 12,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 2,
                      color: Color.fromRGBO(162, 158, 158, 1),
                    ),
                  ),
                  child: TextField(
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    keyboardType: TextInputType.name,
                    cursorColor: Color.fromRGBO(58, 150, 255, 1),
                    decoration: InputDecoration(
                      hintText: 'Enter Group Name',
                      hintStyle: TextStyle(
                        fontFamily: 'Roboto',
                        color: Color.fromRGBO(162, 158, 158, 1),
                        fontSize: 18,
                      ),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    controller: _groupName,
                  ),
                ),
                SizedBox(
                  height: size.height / 50,
                ),
                ElevatedButton(
                  onPressed: createGroup,
                  child: Text("Create Group"),
                ),
              ],
            ),
    );
  }
}


//