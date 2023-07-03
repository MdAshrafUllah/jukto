import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class searchPerson extends StatefulWidget {
  const searchPerson({Key? key});

  @override
  State<searchPerson> createState() => _searchPersonState();
}

class _searchPersonState extends State<searchPerson> {
  String name = "";
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    if (auth.currentUser != null) {
      user = auth.currentUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
              color: Colors.black54,
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
                name = val;
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
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
                        return ListTile(
                          title: Text(
                            data['name'] ?? ' ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            data['email'] ?? ' ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(data['profileImage'] ?? ' '),
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
    );
  }
}
