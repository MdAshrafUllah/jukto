import 'dart:io';

import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jukto/inside/friendList.dart';
import 'package:jukto/inside/notificationPage.dart';
import 'package:provider/provider.dart';

import '../theme/theme.dart';
import 'homePage.dart';
import '../message/messagePage.dart';
import 'profilePage.dart';
import 'searchPage.dart';

class welcomePage extends StatefulWidget {
  const welcomePage({super.key});

  @override
  State<welcomePage> createState() => _welcomePageState();

  static void setStatus(String s) {}
}

IconData _iconLight = Icons.light_mode;
IconData _iconDark = Icons.dark_mode;

class _welcomePageState extends State<welcomePage> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  String userID = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
          setStatus("Online");
        });
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void setStatus(String status) async {
    if (auth.currentUser != null) {
      await FirebaseFirestore.instance.collection('users').doc(userID).update({
        "status": status,
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus("Online");
    } else {
      setStatus("Offline");
    }
  }

  static const List<TabItem> items = [
    TabItem(
      icon: FontAwesomeIcons.house,
    ),
    TabItem(
      icon: FontAwesomeIcons.solidComment,
    ),
    TabItem(
      icon: FontAwesomeIcons.magnifyingGlass,
    ),
    TabItem(
      icon: Icons.notifications,
    ),
    TabItem(
      icon: FontAwesomeIcons.solidUser,
    ),
  ];

  final List<Widget> _pages = [
    HomePage(),
    MessagePage(),
    SearchPerson(),
    NotificationPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return WillPopScope(
      onWillPop: () async => _onBackbuttonpressed(context),
      child: Scaffold(
        /* app bar here */
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
          actions: <Widget>[
            Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: Icon(Icons.menu),
                  color: Colors.white,
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                );
              },
            ),
          ],
        ),
        /* drawer here */
        endDrawer: Drawer(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: Icon(
                          themeProvider.isDarkMode ? _iconDark : _iconLight),
                      title: Text(
                        'Dark Mode',
                        style: TextStyle(
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      trailing: ChangeThemeButtonWidget(),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.people,
                      ),
                      title: Text(
                        'Your Friends',
                        style: TextStyle(
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => FriendList(),
                          ),
                        ).then((_) {
                          Navigator.pop(
                              context); // Close the drawer when returning to the page
                        });
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                splashColor: Colors.red,
                leading: Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                title: Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 18,
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                onTap: () async {
                  setStatus("Offline");
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushNamed(context, '/');
                },
              ),
            ],
          ),
        ),

        /* body start here*/
        body: Center(
          child: _pages[_selectedIndex],
        ),
        bottomNavigationBar: Container(
          child: BottomBarInspiredOutside(
            items: items,
            backgroundColor: Color.fromRGBO(58, 150, 255, 1),
            color: Colors.white,
            colorSelected: Colors.white,
            indexSelected: _selectedIndex,
            onTap: (int index) => setState(() {
              _selectedIndex = index;
            }),
            top: -25,
            animated: true,
            itemStyle: ItemStyle.circle,
            chipStyle:
                const ChipStyle(notchSmoothness: NotchSmoothness.softEdge),
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackbuttonpressed(BuildContext context) async {
    bool exitApp = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Really ?"),
            content: const Text("Do you want to close the app ?"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () {
                  exit(0);
                },
                child: const Text("Yes"),
              ),
            ],
          );
        });
    return exitApp;
  }
}
