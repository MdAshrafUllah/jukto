// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, unused_element

import 'dart:io';

import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jukto/Nevigation/notification_page.dart';
import 'package:jukto/alarm/event_calendar.dart';
import 'package:jukto/info/about.dart';
import 'package:jukto/info/terms_and_conditions.dart';
import 'package:jukto/Nevigation/message_page.dart';
import 'package:jukto/useruse/ebooks_page.dart';
import 'package:jukto/useruse/friend_list.dart';
import 'package:jukto/useruse/sent_request_list.dart';
import 'package:jukto/useruse/settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../theme/theme.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'search_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();

  static void setStatus(String s) {}
}

IconData _iconLight = Icons.light_mode;
IconData _iconDark = Icons.dark_mode;

class _WelcomePageState extends State<WelcomePage> with WidgetsBindingObserver {
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
        for (var doc in querySnapshot.docs) {
          String documentId = doc.id;
          userID = documentId;
          setStatus("Online");
        }
      });
    }
    requestAndCheckPermissions();
  }

  Future<void> requestAndCheckPermissions() async {
    // Check if camera permission is already granted
    PermissionStatus cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      // Request camera permission
      await Permission.camera.request();
    }

    // Check if file permission is already granted
    PermissionStatus fileStatus = await Permission.storage.status;
    if (!fileStatus.isGranted) {
      // Request file permission
      await Permission.storage.request();
    }

    // Check if notification permission is already granted
    PermissionStatus notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      // Request notification permission
      await Permission.notification.request();
    }

    // Check if photo permission is already granted
    PermissionStatus photoStatus = await Permission.photos.status;
    if (!photoStatus.isGranted) {
      // Request notification permission
      await Permission.photos.request();
    }
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
    const HomePage(),
    const MessagePage(),
    const SearchPerson(),
    const NotificationPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return WillPopScope(
      onWillPop: () async => _onBackbuttonpressed(context),
      child: Scaffold(
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
          iconTheme: const IconThemeData(color: Colors.white, size: 35.0),
          actions: <Widget>[
            Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
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
                      trailing: const ChangeThemeButtonWidget(),
                    ),
                    ListTile(
                      leading: const Icon(
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
                            builder: (BuildContext context) =>
                                const FriendList(),
                          ),
                        ).then((_) {
                          Navigator.pop(
                              context); // Close the drawer when returning to the page
                        });
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.arrow_upward_rounded,
                      ),
                      title: Text(
                        'Sent Request',
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
                            builder: (BuildContext context) =>
                                const SentRequestPage(),
                          ),
                        ).then((_) {
                          Navigator.pop(
                              context); // Close the drawer when returning to the page
                        });
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.event,
                      ),
                      title: Text(
                        'Events',
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
                            builder: (BuildContext context) =>
                                const EventSchedulerPage(),
                          ),
                        ).then((_) {
                          Navigator.pop(
                              context); // Close the drawer when returning to the page
                        });
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.book_online,
                      ),
                      title: Text(
                        'E-Books',
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
                            builder: (BuildContext context) =>
                                const EbooksPage(),
                          ),
                        ).then((_) {
                          Navigator.pop(
                              context); // Close the drawer when returning to the page
                        });
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.settings,
                      ),
                      title: Text(
                        'Settings',
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
                            builder: (BuildContext context) =>
                                const SettingsPage(),
                          ),
                        ).then((_) {
                          Navigator.pop(
                              context); // Close the drawer when returning to the page
                        });
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.newspaper,
                      ),
                      title: Text(
                        'Terms and Conditions',
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
                            builder: (BuildContext context) =>
                                const TermsandConditions(),
                          ),
                        ).then((_) {
                          Navigator.pop(
                              context); // Close the drawer when returning to the page
                        });
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.info,
                      ),
                      title: Text(
                        'About The App',
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
                            builder: (BuildContext context) => const AboutApp(),
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
                leading: const Icon(
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
                  Future<void> _deleteAppDir() async {
                    Directory appDocDir =
                        await getApplicationDocumentsDirectory();

                    if (appDocDir.existsSync()) {
                      appDocDir.deleteSync(recursive: true);
                    }
                  }

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
        bottomNavigationBar: BottomBarInspiredOutside(
          items: items,
          backgroundColor: const Color.fromRGBO(58, 150, 255, 1),
          color: Colors.white,
          colorSelected: Colors.white,
          indexSelected: _selectedIndex,
          onTap: (int index) => setState(() {
            _selectedIndex = index;
          }),
          top: -25,
          animated: true,
          itemStyle: ItemStyle.circle,
          chipStyle: const ChipStyle(notchSmoothness: NotchSmoothness.softEdge),
        ),
      ),
    );
  }

  Future<bool> _onBackbuttonpressed(BuildContext context) async {
    bool exitApp = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Really ?",
              style: TextStyle(
                  color: Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.white
                      : Colors.black),
            ),
            content: Text("Do you want to close the app ?",
                style: TextStyle(
                    color: Provider.of<ThemeProvider>(context).isDarkMode
                        ? Colors.white
                        : Colors.black)),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text(
                  "No",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
              ElevatedButton(
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
